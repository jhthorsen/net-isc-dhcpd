package Net::ISC::DHCPd::OMAPI::Lease;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Lease

=head1 NOTICE

This module will be changed! Attribute names and behaviour.

=cut

use Moose;

with 'Net::ISC::DHCPd::OMAPI::Role';

=head1 ATTRIBUTES

=head2 atsfp

=head2 client_hostname

=head2 cltt

=head2 dhcp_client_identifier

=head2 flags

=head2 ends

=head2 hardware_address

=head2 hardware_type

=head2 ip_address

=head2 leasetime

=head2 pool

=head2 starts

=head2 state

=head2 subnet

=head2 tsfp

=head2 tstp

=cut

has [qw/
    ip_address state dhcp_client_identifier client_hostname
    subnet pool hardware_address hardware_type ends starts
    tstp tsfp cltt atsfp flags leasetime
/] => (
    is => 'rw',
    isa => 'Str',
);

=head2 hw_addr

Alias for L<hardware_address>.

=cut

# hack
has hw_addr => ( is => 'rw' );
around hw_addr => sub { shift; shift->hardware_address(@_) };

=head1 METHODS

=head2 primary

 $str = $self->primary;

Returns the primary key for this object: "ip_address".

=cut

sub primary { 'ip_address' }

=head2 normalize_ip_address

 $human_value = $self->normalize_ip_address($omapi_value);

=cut

sub normalize_ip_address {
    return join ".", map { hex $_ } split /:/, $_[1]
}

=head2 normalize_state

 $human_value = $self->normalize_state($omapi_value);

=cut

sub normalize_state {
    my $value = ($_[1] =~ /(\d+)$/)[0];
    my @state = qw/
        0 free active expired released abandoned reset backup reserved bootp
    /;
    return $value ? $state[$value] : $_[1];
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
