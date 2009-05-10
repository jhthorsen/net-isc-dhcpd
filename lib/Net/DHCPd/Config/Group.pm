package Net::DHCPd::Config::Group;

=head1 NAME

Net::DHCPd::Config::Group - Group config parameter

=head1 SYNOPSIS

 my $group = Net::DHCPd::Config::Group->new;

 for($group->subnets) {
    #...
 }
 for($group->hosts) {
    #...
 }
 for($group->options) {
    #...
 }

=cut

use Moose;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::KeyValue;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 subnets

A list of parsed L<Net::DHCPd::Config::Subnet> objects.

=head2 hosts

A list of parsed L<Net::DHCPd::Config::Host> objects.

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=cut

has '+_children' => (
    default => sub { 
        shift->create_children(qw/
            Net::DHCPd::Config::Subnet
            Net::DHCPd::Config::Host
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::KeyValue
        /);
    },
);

=head2 regex

See L<Net::DHCPd::Config::Role>

=cut

has '+regex' => (
    default => sub { qr{^ \s* group}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
