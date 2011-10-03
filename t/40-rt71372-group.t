use warnings;
use strict;
use lib qw(lib);
use Test::More;
BEGIN { $ENV{'ISC_DHCPD_TRACE'} = 1 }
use Net::ISC::DHCPd::Config;

plan skip_all => 'no t/data/rt71372.conf' unless(-r 't/data/rt71372.conf');
plan tests => 12;

{
    my $config = Net::ISC::DHCPd::Config->new(file => 't/data/rt71372.conf');
    my @subnets;

    $config->parse;

    is(scalar(@_=$config->includes), 1, "includes");
    is(scalar(@_=$config->keys), 1, "keys");
    is(scalar(@_=$config->keyvalues), 10, "key values");
    is(scalar(@_=$config->options), 2, "options");
    is(scalar(@_=$config->subnets), 1, "subnets");
    is(scalar(@_=$config->groups), 1, "groups");
    is(scalar(@_=$config->blocks), 0, "blocks");
    is(scalar(@subnets=$config->subnets), 1, "subnets");
    is(scalar(@_=$subnets[0]->options), 9, "subnet -> options");
    is(scalar(@_=$subnets[0]->keyvalues), 2, "subnet -> keyvalues");
    is(scalar(@_=$subnets[0]->pools), 2, "subnet -> pools");
    
    local $TODO = 'should be parsed as class{}';
    is(scalar(@_=$subnets[0]->blocks), 2, "subnet -> blocks");
}
