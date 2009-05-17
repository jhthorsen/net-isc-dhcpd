package Net::DHCPd::Config::SharedNetwork;

=head1 NAME

Net::DHCPd::Config::SharedNetwork - shared-network config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::DHCPd::Config::Subnet
    Net::DHCPd::Config::KeyValue
/);

=head1 OBJECT ATTRIBUTES

=head2 subnets

A list of parsed L<Net::DHCPd::Config::Subnet> objects.

=head2 keyvalues

A list of parsed L<Net::DHCPd::Config::KeyValue> objects.

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* shared-network}x },
);

=head1 METHODS

=head2 generate

=cut

sub generate {
    return(
        "shared-network {",
        shift->generate_config_from_children,
        "}",
    );
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
