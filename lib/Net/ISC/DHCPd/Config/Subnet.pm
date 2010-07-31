package Net::ISC::DHCPd::Config::Subnet;

=head1 NAME

Net::ISC::DHCPd::Config::Subnet - Subnet config parameter

=cut

use Moose;
use NetAddr::IP;
use Net::ISC::DHCPd::Config::Option;
use Net::ISC::DHCPd::Config::Range;
use Net::ISC::DHCPd::Config::Host;
use Net::ISC::DHCPd::Config::Filename;
use Net::ISC::DHCPd::Config::Pool;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Pool
    Net::ISC::DHCPd::Config::Range
    Net::ISC::DHCPd::Config::Filename
    Net::ISC::DHCPd::Config::Option
/);

=head1 OBJECT ATTRIBUTES

=head2 address

The ip address of this subnet.

ISA: L<NetAddr::IP>

=cut

has address => (
    is => 'ro',
    isa => 'NetAddr::IP',
);

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=head2 ranges

A list of parsed L<Net::ISC::DHCPd::Config::Range> objects.

=head2 hosts

A list of parsed L<Net::ISC::DHCPd::Config::Host> objects.

=head2 filenames

A list of parsed L<Net::ISC::DHCPd::Config::Filename> objects.

Should only be one item in this list.

=head2 pools

A list of parsed L<Net::ISC::DHCPd::Config::Pool> objects.

=head2 regex

=cut

sub _build_regex { qr{^ \s* subnet \s (\S+) \s netmask \s (\S+) }x }

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { address => NetAddr::IP->new(join "/", @_[1,2]) };
}

=head2 generate

=cut

sub generate {
    my $self = shift;
    my $addr = $self->address;

    return(
        sprintf("subnet %s netmask %s {", $addr->addr, $addr->mask),
        $self->generate_config_from_children,
        "}",
    );
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
