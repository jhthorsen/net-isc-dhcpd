package Net::DHCPd::Config::Role;

=head1 NAME

Net::DHCPd::Config::Role - Generic config methods and attributes

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose::Role;

=head1 OBJECT ATTRIBUTES

=head2 parent

The parent node in the config tree.

=cut

has parent => (
    is => 'rw',
    isa => 'Net::DHCPd::Config::Role',
    weak_ref => 1,
);

=head2 root

The root node in the config tree.

=cut

has root => (
    is => 'ro',
    isa => 'Net::DHCPd::Config',
    lazy => 1,
    weak_ref => 1,
    default => sub {
        my $self = shift;
        my $obj  = $self;

        while(my $tmp = $obj->parent) {
            ref($obj = $tmp) eq "Net::DHCPd::Config" and last;
        }

        return $obj;
    },
);

=head2 depth

How far this node is from the root node.

=cut

has depth => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

=head2 children

List of possible child nodes.

=cut

has children => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    default => sub { [] },
);

=head2 regex

Regex to match for the node to be added.

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
);

=head2 endpoint

Regex to search for before ending the current node block.

Will not be used if the node does not have any possible L<children>.

=cut

has endpoint => (
    is => 'ro',
    isa => 'Maybe[RegexpRef]',
    default => sub { qr" ^ \s* } \s* $ "x },
);

=head1 METHODS

=head2 parse

 $int = $self->parse;

Parses a current node recursively. Does this by reading line by line from
L<$self-E<gt>root-E<gt>filehandle>, and use the rules from the possible
child elements and endpoint.

=cut

sub parse {
    my $self     = shift;
    my $fh       = $self->root->filehandle;
    my $endpoint = $self->endpoint;
    my $n        = 0;

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
            my $add = "add_" .lc +(ref($child) =~ /::(\w+)$/)[0];
            my $new = $self->$add( $child->captured_to_args(@c) );

            $n += $new->parse if(@_ = $new->children);

            last CHILD;
        }
    }

    return $n ? $n : "0e0";
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
        my $class = $obj; # bareword classname
        my $name  = lc +($class =~ /::(\w+)$/)[0];
        my $acc   = $name ."s";

        unless($meta->get_attribute($acc)) {
            $meta->add_attribute($acc => (
                is => "rw",
                isa => "ArrayRef[$class]",
                lazy => 1,
                auto_deref => 1,
                default => sub { [] },
            ));
            $meta->add_method("add_${name}" => sub {
                my $self = shift;
                my $args = @_ == 1 ? $_[0] : {@_};
                my $new  = $class->new($args);

                $new->parent($self);
                $new->depth($self->depth + 1);

                for my $e (values %$args) {
                    next unless(ref $e eq 'ARRAY');
                    for my $o (@$e) {
                        $o->does(__PACKAGE__) or next;
                        $o->parent or $o->parent($new);
                        $o->depth  or $o->depth($new->depth);
                    }
                }

                push @{ $self->$acc }, $new;
                return $new;
            });
        }

        # replace class bareword with object in @list
        $obj = $obj->new;
    }

    unless(blessed $self) {
        $meta->add_attribute($meta->get_attribute('children')->clone(
            default => sub { \@list },
        ));
    }

    return \@list;
}

=head2 generate_config_from_children

 $config_text = $self->generate_config_from_children;

Loops all child node and calls L<generate()>.

=cut

sub generate_config_from_children {
    my $self   = shift;
    my $indent = "    " x $self->depth;
    my @text;

    for($self->children) {
        my($acc) = lc +((blessed $_) =~ /::(\w+)$/ )[0] ."s";

        for my $child ($self->$acc) {
            push @text, map { "$indent$_" } $child->generate;
        }
    }

    return join "\n", @text;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
