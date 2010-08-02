package Net::ISC::DHCPd::Config::Group;

=head1 NAME

Net::ISC::DHCPd::Config::Group - Group config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 ATTRIBUTES

=head2 subnets

A list of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 hosts

A list of parsed L<Net::ISC::DHCPd::Config::Host> objects.

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=cut

sub _build_regex { qr{^ \s* group}x }

=head2 generate

See L<Net::ISC::DHCPd::Config::Role::generate()>.

=cut

sub generate {
    return 'group {', shift->generate_config_from_children, '}';
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
