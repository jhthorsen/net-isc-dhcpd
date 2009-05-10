#!perl

use warnings;
use strict;
use Net::DHCPd::Config;
use Test::More tests => 9;

my $config = Net::DHCPd::Config->new(filehandle => \*DATA);

is(ref $config, "Net::DHCPd::Config", "config object constructed");
is($config->parse, 38, "all config lines parsed");

is(scalar(@_=$config->keyvalues), 3, "key values parsed");
is(scalar(@_=$config->optionspaces), 1, "option namespaces parsed");
is(scalar(@_=$config->options), 1, "option parsed");
is(scalar(@_=$config->subnets), 1, "subnet parsed");
is(scalar(@_=$config->hosts), 1, "host parsed");

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
ddns-update-style none;

option space foo;
option foo.bar code 1 = ip-address;
option foo.baz code 2 = ip-address;
option foo-enc code 122 = encapsulate foo;

option domain-name-servers 84.208.20.110, 84.208.20.111;
default-lease-time 86400;
max-lease-time 86400;

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

host foo {
  hardware ethernet 00:0e:35:d1:27:e3;
  fixed-address 10.19.83.102;
}

