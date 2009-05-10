package Net::DHCPd::Config::Subnet;

=head1 NAME

Net::DHCPd::Config::Subnet - Subnet config parameter

=cut

use Moose;
use NetAddr::IP;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Range;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Filename;
use Net::DHCPd::Config::Pool;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 address

=cut

has address => (
    is => 'ro',
    isa => 'NetAddr::IP',
);

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 ranges

A list of parsed L<Net::DHCPd::Config::Range> objects.

=head2 hosts

A list of parsed L<Net::DHCPd::Config::Host> objects.

=head2 filenames

A list of parsed L<Net::DHCPd::Config::Filename> objects.

Should only be one item in this list.

=head2 pools

A list of parsed L<Net::DHCPd::Config::Pool> objects.

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::Range
            Net::DHCPd::Config::Host
            Net::DHCPd::Config::Filename
            Net::DHCPd::Config::Pool
        /);
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* subnet \s (\S+) \s netmask \s (\S+) }x },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { address => NetAddr::IP->new(join "/", @_[1,2]) };
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
