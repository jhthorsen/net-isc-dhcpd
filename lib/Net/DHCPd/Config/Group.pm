package Net::DHCPd::Config::Group;

=head1 NAME

Net::DHCPd::Config::Group - Group config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::KeyValue;

with 'Net::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::DHCPd::Config::Host
    Net::DHCPd::Config::Option
    Net::DHCPd::Config::KeyValue
/);

=head1 OBJECT ATTRIBUTES

=head2 subnets

A list of parsed L<Net::DHCPd::Config::Subnet> objects.

=head2 hosts

A list of parsed L<Net::DHCPd::Config::Host> objects.

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* group}x },
);

=head2 generate

=cut

sub generate {
    return(
        'group {',
        shift->generate_config_from_children,
        '}',
    );
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
