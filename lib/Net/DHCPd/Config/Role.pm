package Net::DHCPd::Config::Role;

=head1 NAME

Net::DHCPd::Config::Role - Generic config methods and attributes

=cut

use Moose::Role;

=head1 OBJECT ATTRIBUTES

=head2 parent

=cut

has parent => (
    is => 'ro',
    isa => 'Net::DHCPd::Config::Role',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
);

=head2 root

=cut

has root => (
    is => 'ro',
    isa => 'Net::DHCPd::Config',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
);

=head2 children

=cut

has children => (
    is => 'rw',
    isa => 'ArrayRef',
    auto_deref => 1,
    default => sub { [] },
);

has _children => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    default => sub { [] },
);

=head2 regex

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
);

=head2 endpoint

=cut

has endpoint => (
    is => 'ro',
    isa => 'Maybe[RegexpRef]',
    default => sub { qr" ^ \s* } \s* $ "x },
);

=head1 METHODS

=head2 parse

 $int = $self->parse;

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
            last LINE;
        }

        CHILD:
        for my $child ($self->_children) {
            my @captured = $line =~ $child->regex or next CHILD;
            $self->add_child($child, @captured);
            $n += $child->parse if(@_ = $child->_children);
            last CHILD;
        }
    }

    return $n ? $n : "0e0";
}

=head2 add_child

 $obj = $self->add_child($child, @captured)

Called from L<parse()>, with the child object and the captured elements
from the L<regex()>.

This role provides a default method that does nothing. Should be overriden
in each class.

=cut

sub add_child {
}

=head2 create_children

 $objs = $self->create_children(@classnames)

=cut

sub create_children {
    my $self = shift;
    my @obj  = @_;

    for(@obj) {
        $_ = $_->new(root => $self->root, parent => $self);
    }

    return \@obj;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
