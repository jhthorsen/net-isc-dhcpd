package Net::DHCPd::Config::Range;

=head1 NAME

Net::DHCPd::Config::Range - IP range config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* range \s (\S+) \s (\S*)}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
