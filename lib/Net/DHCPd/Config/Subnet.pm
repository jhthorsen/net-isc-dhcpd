package Net::DHCPd::Config::Subnet;

=head1 NAME

Net::DHCPd::Config::Subnet - Subnet config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 children

=cut

has '+children' => (
    default => sub {
        [
            Net::DHCPd::Config::Option->new,
            Net::DHCPd::Config::Range->new,
            Net::DHCPd::Config::Host->new,
            Net::DHCPd::Config::Filename->new,
            Net::DHCPd::Config::Pool->new,
        ],
    },
);

=head2 regex

=cut

has '+regex' => (
    default => qr{subnet \s (\S+) \s netmask (\S+)}x,
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
