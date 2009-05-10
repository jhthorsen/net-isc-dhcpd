package Net::DHCPd::Config::Pool;

=head1 NAME

Net::DHCPd::Config::Pool - Pool config parameter

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Range;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::Range
        /);
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* pool}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
