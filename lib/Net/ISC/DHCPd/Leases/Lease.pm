package Net::ISC::DHCPd::Leases::Lease;

=head1 NAME

Net::ISC::DHCPd::Leases::Lease - Lease object

=head1 DESCRIPTION

This class extends L<Net::ISC::DHCPd::OMAPI::Lease>.

=cut

use Moose;

extends 'Net::ISC::DHCPd::OMAPI::Lease';

has '+parent' => ( required => 0 );

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
