package Net::ISC::DHCPd::Config::Role;

=head1 NAME

Net::ISC::DHCPd::Config::Role - Generic config methods and attributes

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose::Role;

=head1 OBJECT ATTRIBUTES

=head2 parent

The parent node in the config tree.

=cut

has parent => (
    is => 'rw',
    isa => 'Net::ISC::DHCPd::Config::Role',
    weak_ref => 1,
);

=head2 root

The root node in the config tree.

=cut

has root => (
    is => 'ro',
    isa => 'Net::ISC::DHCPd::Config',
    lazy => 1,
    weak_ref => 1,
    builder => '_build_root',
);

sub _build_root {
    my $obj = shift;

    while(my $tmp = $obj->parent) {
        blessed($obj = $tmp) eq 'Net::ISC::DHCPd::Config' and last;
    }

    return $obj;
}

=head2 depth

How far this node is from the root node.

=cut

has depth => (
    is => 'ro',
    isa => 'Int',
    lazy => 1,
    builder => '_build_depth',
);

sub _build_depth {
    my $self = shift;
    my $obj = $self;
    my $i = 0;

    while($obj = $obj->parent) {
        $i++;
        last if($obj == $self->root);
    }

    return $i;
}

=head2 children

List of possible child nodes.

=cut

has children => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    builder => '_build_children',
);

sub _build_children { [] }

=head2 regex

Regex to match for the node to be added.

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
    builder => '_build_regex',
);

=head2 endpoint

Regex to search for before ending the current node block.

Will not be used if the node does not have any possible L<children>.

=cut

has endpoint => (
    is => 'ro',
    isa => 'Maybe[RegexpRef]',
    builder => '_build_endpoint',
);

sub _build_endpoint { qr" ^ \s* } \s* $ "x }

=head1 METHODS

=head2 parse

 $int = $self->parse;

Parses a current node recursively. Does this by reading line by line from
L<$self-E<gt>root-E<gt>filehandle>, and use the rules from the possible
child elements and endpoint.

=cut

sub parse {
    my $self = shift;
    my $fh = $self->root->filehandle;
    my $endpoint = $self->endpoint;
    my $n = 0;

    LINE:
    while(++$n) {
        my $line = readline $fh;
        my $res;

        if(not defined $line) {
            $n--;
            last LINE;
        }

        if($self->can('slurp')) {
            my $action = $self->slurp($line); # next or last
            no warnings;
            eval $action;
        }

        if($line =~ $endpoint) {
            $self->captured_endpoint($1, $2, $3, $4); # urk...

            if($self->root == $self) {
                next LINE;
            }
            else {
                last LINE;
            }
        }

        CHILD:
        for my $child ($self->children) {
            my @c   = $line =~ $child->regex or next CHILD;
            my $add = 'add_' .lc +(ref($child) =~ /::(\w+)$/)[0];
            my $new = $self->$add( $child->captured_to_args(@c) );

            $n += $new->parse if(@_ = $new->children);

            last CHILD;
        }
    }

    return $n ? $n : '0e0';
}

=head2 captured_to_args

 $hash_ref = $self->captured_to_args(@list);

Called when a L<regex> matches, with a list of captured strings.

=cut

sub captured_to_args {
    return {};
}

=head2 captured_endpoint
 
 $self->captured_endpoint(@list)

Called when a L<endpoint> matches, with a list of captured strings.

=cut

sub captured_endpoint {
    return;
}

=head2 create_children

 My::Class->create_children(@classnames)

This method is used internally to create extra attributes in classes and
construct the L<children> attribute.

=cut

sub create_children {
    my $self = shift;
    my $meta = $self->meta;
    my @list = @_;

    for my $obj (@list) {
        my $class = $obj; # copy classname
        my $name  = lc +($class =~ /::(\w+)$/)[0];
        my $attr  = $name .'s';

        unless($meta->get_attribute($attr)) {
            $meta->add_attribute($attr => (
                is => 'rw',
                isa => 'ArrayRef',
                lazy => 1,
                auto_deref => 1,
                default => sub { [] },
                trigger => sub {
                    for my $e (@{ $_[1] }) {
                        next if(blessed $e);
                        next if(ref $e ne 'HASH');
                        $e = $class->new(parent => $_[0], %$e);
                    }
                },
            ));

            $meta->add_method("add_${name}" => sub {
                my $self = shift;
                my $args = @_ == 1 ? $_[0] : {@_};

                push @{ $self->$attr }, $class->new(%$args, parent => $self);

                return ${ $self->$attr }[-1];
            });
        }

        # replace class bareword with object in @list
        $obj = $class->new;
    }

    unless(blessed $self) {
        $meta->add_method(_build_children => sub { \@list });
    }

    return \@list;
}

=head2 generate_config_from_children

 $config_text = $self->generate_config_from_children;

Loops all child node and calls L<generate()>.

=cut

sub generate_config_from_children {
    my $self = shift;
    my $indent = $self->parent ? (' ' x 4) : '';
    my @text;

    for(reverse $self->children) {
        my($attr) = lc +((blessed $_) =~ /::(\w+)$/ )[0] .'s';

        for my $child ($self->$attr) {
            push @text, map { "$indent$_" } $child->generate;
        }
    }

    return join "\n", @text;
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
