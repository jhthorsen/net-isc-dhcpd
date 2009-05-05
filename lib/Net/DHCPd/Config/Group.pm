package Net::DHCPd::Config::Group;

=head1 NAME

Net::DHCPd::Config::Group - Group config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 children

=cut

has '+children' => (
    default => sub {
        [
            Net::DHCPd::Config::Subnet->new,
            Net::DHCPd::Config::Host->new,
        ],
    },
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* group}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
