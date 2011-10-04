package Net::ISC::DHCPd::Config::Group;

=head1 NAME

Net::ISC::DHCPd::Config::Group - Group config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    group {
        $keyvalues_attribute_value
        $options_attribute_value
        $hosts_attribute_value
        $groups_attribute_value
        $sharednetworks_attribute_value
        $subnets_attribute_value
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Group
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 ATTRIBUTES

=head2 subnets

A list of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 sharednetworks

A list of parsed L<Net::ISC::DHCPd::Config::SharedNetwork> objects.

=head2 groups

A list of parsed L<Net::ISC::DHCPd::Config::Group> objects.

=head2 hosts

A list of parsed L<Net::ISC::DHCPd::Config::Host> objects.

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=head2 keyvalues

A list of parsed L<Net::ISC::DHCPd::Config::KeyValue> objects.

=cut

sub _build_regex { qr{^ \s* group}x }

=head1 METHODS

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    return 'group {', shift->_generate_config_from_children, '}';
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
