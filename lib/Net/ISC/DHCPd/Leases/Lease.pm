package Net::ISC::DHCPd::Leases::Lease;

=head1 NAME

Net::ISC::DHCPd::Leases::Lease - Lease object

=cut

use Moose;

=head1 ATTRIBUTES

=head2 starts

 $str = $self->starts;

=cut

has starts => (
    is => 'ro',
    isa => 'Str',
);

=head2 ends

 $str = $self->ends;

=cut

has ends => (
    is => 'ro',
    isa => 'Str',
);

=head2 binding

 $str = $self->binding;

=cut

has binding => (
    is => 'ro',
    isa => 'Str',
);

=head2 hw_ethernet

 $str = $self->hw_ethernet;

=cut

has hw_ethernet => (
    is => 'ro',
    isa => 'Str',
);

=head2 hostname

 $str = $self->hostname;

=cut

has hostname => (
    is => 'ro',
    isa => 'Str',
);

=head2 circuit_id

 $str = $self->circuit_id;

=cut

has circuit_id => (
    is => 'ro',
    isa => 'Str',
);

=head2 remote_id

 $str = $self->remote_id;

=cut

has remote_id => (
    is => 'ro',
    isa => 'Str',
);

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
