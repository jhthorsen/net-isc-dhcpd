package Net::ISC::DHCPd::Config::SharedNetwork;

=head1 NAME

Net::ISC::DHCPd::Config::SharedNetwork - Shared-network config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 ATTRIBUTES

=head2 subnets

A list of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 keyvalues

A list of parsed L<Net::ISC::DHCPd::Config::KeyValue> objects.

=cut

sub _build_regex { qr{^\s* shared-network}x }

=head1 METHODS

=head2 generate

See L<Net::ISC::DHCPd::Config::Role::generate()>.

=cut

sub generate {
    return(
        'shared-network {',
        shift->generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
