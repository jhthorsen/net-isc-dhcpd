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
    is => 'ro',
    isa => 'Net::DHCPd::Config::Role',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
);

=head2 root

The root node in the config tree.

=cut

has root => (
    is => 'ro',
    isa => 'Net::DHCPd::Config',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
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

=head2 pairs

...

=cut

has pairs => (
    is => 'ro',
    isa => 'ArrayRef[RegexpRef]',
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
        if($line =~ $endpoint) {
            warn "=endpoint\n" if $Net::DHCPd::Config::DEBUG;

            $self->captured_endpoint($1, $2, $3, $4); # urk...

            if($self->root == $self) {
                next LINE;
            }
            else {
                last LINE;
            }
        }

        warn ":$self: $line" if $Net::DHCPd::Config::DEBUG;

        CHILD:
        for my $child ($self->children) {
            my @captured = $line =~ $child->regex or next CHILD;
            my $new      = $self->append($child, @captured);

            warn ">$new: @captured\n" if $Net::DHCPd::Config::DEBUG;

            $n += $new->parse if(@_ = $new->children);

            last CHILD;
        }
    }

    return $n ? $n : "0e0";
}

=head2 append

 $new_child = $self->append($child, @captured)

Called from L<parse()>, with the child object and the captured elements
from the L<regex()>.

This role provides a default method that does nothing. Should be overriden
in each class.

=cut

sub append {
    my $self  = shift;
    my $child = shift;
    my $args  = $child->captured_to_args(@_);
    my $type  = lc +(ref($child) =~ /::(\w+)$/)[0] ."s";
    my $new   = $child->meta->clone_object($child, %$args);

    push @{ $self->$type }, $new;

    return $new;
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

 $objs = $self->create_children(@classnames)

This method is used internally to create extra attributes in classes and
construct the L<children> attribute.

=cut

sub create_children {
    my $self = shift;
    my $meta = $self->meta;
    my @list = @_;

    for my $obj (@list) {
        my $name = lc +($obj =~ /::(\w+)$/)[0] ."s";

        unless($meta->get_attribute($name)) {
            $meta->add_attribute($name => (
                is => "rw",
                isa => "ArrayRef[$obj]",
                lazy => 1,
                auto_deref => 1,
                default => sub { [] },
            ));
        }

        $obj = $obj->new(root => $self->root, parent => $self);
    }

    return \@list;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
