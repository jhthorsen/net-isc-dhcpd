package Net::DHCPd::Config::Pool;

=head1 NAME

Net::DHCPd::Config::Pool - Pool config parameter

=head1 SYNOPSIS

 $pool = Net::DHCPd::Config::Pool->new;

 for($pool->options) {
    # ...
 }
 for($pool->ranges) {
    # ...
 }

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Range;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 ranges

A list of parsed L<Net::DHCPd::Config::Range> objects.

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

See L<Net::DHCPd::Config::Role>.

=cut

has '+regex' => (
    default => sub { qr{^ \s* pool}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
