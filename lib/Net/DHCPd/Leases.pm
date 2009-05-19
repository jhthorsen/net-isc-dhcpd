package Net::DHCPd::Leases;

=head1 NAME 

Net::DHCPd::Leases - Parse ISC DHCPd leases

=cut

use Moose;

=head1 OBJECT ATTRIBUTES

=head2 file

=cut

has file => (
    is => 'rw',
    isa => 'Str',
    default => "/var/lib/dhcp3/dhcpd.leases",
);

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
