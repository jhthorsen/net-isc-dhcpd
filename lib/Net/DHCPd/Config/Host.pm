package Net::DHCPd::Config::Host;

=head1 NAME

Net::DHCPd::Config::Host - Host config parameter

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
            Net::DHCPd::Config::Filename->new,
        ],
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* host (\S+)}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
