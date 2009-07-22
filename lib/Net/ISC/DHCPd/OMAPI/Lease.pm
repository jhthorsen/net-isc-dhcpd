package Net::ISC::DHCPd::OMAPI::Lease;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Lease

=head1 NOTICE

This module will be changed! Attribute names and behaviour.

=cut

use Moose;

with 'Net::ISC::DHCPd::OMAPI::Role';

=head1 ATTRIBUTES

=head2 ip_address

=head2 state

=head2 dhcp_client_identifier

=head2 client_hostname

=head2 subnet

=head2 pool

=head2 hardware_address

=head2 hardware_type

=head2 ends

=head2 starts

=head2 tstp

=head2 tsfp

=head2 cltt

=cut

has [qw/
    ip_address state dhcp_client_identifier client_hostname
    subnet pool hardware_address hardware_type ends starts
    tstp tsfp cltt
/] => (
    is => 'rw',
    isa => 'Str',
);

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
