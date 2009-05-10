package Net::DHCPd::Config::Host;

=head1 NAME

Net::DHCPd::Config::Host - Host config parameter

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Filename;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::Filename
        /);
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* host (\S+)}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
