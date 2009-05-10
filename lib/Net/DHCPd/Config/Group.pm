package Net::DHCPd::Config::Group;

=head1 NAME

Net::DHCPd::Config::Group - Group config parameter

=cut

use Moose;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Option;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=cut

has '+_children' => (
    default => sub { 
        shift->create_children(qw/
            Net::DHCPd::Config::Subnet
            Net::DHCPd::Config::Host
            Net::DHCPd::Config::Option
        /);
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
