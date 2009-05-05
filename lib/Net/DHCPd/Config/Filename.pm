package Net::DHCPd::Config::Filename;

=head1 NAME

Net::DHCPd::Config::Filename - Filename config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 regex

=cut

has '+regex' => (
    default => qr{^\s* filename \s (\S+)}x,
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
