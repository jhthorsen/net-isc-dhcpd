package Net::DHCPd::Config::Pool;

=head1 NAME

Net::DHCPd::Config::Pool - Pool config parameter

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
        ],
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* pool \s* {? $}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
