package Net::DHCPd::Config::Option;

=head1 NAME

Net::DHCPd::Config::Option - Option config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* option \s (\S+) \s (\S*)}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
