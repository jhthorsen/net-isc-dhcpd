package Net::ISC::DHCPd::OMAPI;

=head1 NAME

Net::ISC::DHCPd::OMAPI - Talk to dhcp server

=cut

use Moose;

=head1 ATTRIBUTES

=head2 server

=cut

has server => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1',
);

=head2 port

=cut

has port => (
    is => 'ro',
    isa => 'Int',
    default => 7911,
);

=head2 key

=cut

has key => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

=head1 METHODS

=head2 connect

 $bool = $self->connect;

=cut

sub connect {
    my $self = shift;
}

=head2 new_object

 $object = $self->new_object($type);

C<$type> can be group, host, or lease.

=cut

sub new_object {
    my $self  = shift;
    my $type  = shift or return;
    my $class = __PACKAGE__ ."::" .ucfirst($type);

    eval "use $class" or confess $@;

    return $class->new;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
