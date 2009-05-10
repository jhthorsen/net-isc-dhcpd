#!perl

use warnings;
use strict;
use Net::DHCPd::Config;
use Test::More tests => 9;

my $config = Net::DHCPd::Config->new(filehandle => \*DATA);

is(ref $config, "Net::DHCPd::Config", "config object constructed");
is($config->parse, 21, "21 lines of config parsed");
is(scalar(@_=$config->subnets), 1, "one subnet is found");

my $subnet = $config->subnets->[0];
my $option = $subnet->options->[0];

is($option->name, "domain-name", "domain name option found");
is($option->value, "isc.org", "domain name value found");
ok($option->quoted, "domain name value is quoted");
is(scalar(@_=$subnet->pools), 3, "three pools found");

my $range = $subnet->pools->[0]->ranges->[0];
is($range->lower, "10.0.0.98/32", "lower pool range is ok");
is($range->upper, "10.0.0.103/32", "upper pool range is ok");

__DATA__
   subnet 10.0.0.96 netmask 255.255.255.224
   {
       option domain-name "isc.org";
       option domain-name-servers ns1.isc.org, ns2.isc.org;
       option routers 10.0.0.97;

       pool {
    
           range 10.0.0.98 10.0.0.103;
       }
       pool
       {

           range 10.0.0.105 10.0.0.114;
       }
       pool
       {

           range 10.0.0.116 10.0.0.126;
       }
   }
