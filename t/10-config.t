#!perl

use warnings;
use strict;
use Net::DHCPd::Config;
use Test::More tests => 24;

#$Net::DHCPd::Config::DEBUG = 1;

my $config = Net::DHCPd::Config->new(filehandle => \*DATA);

is(ref $config, "Net::DHCPd::Config", "config object constructed");
is($config->parse, 49, "all config lines parsed");

is(scalar(@_=$config->keyvalues), 3, "key values");
is(scalar(@_=$config->optionspaces), 1, "option space");
is(scalar(@_=$config->options), 1, "options");
is(scalar(@_=$config->subnets), 1, "subnets");
is(scalar(@_=$config->hosts), 1, "hosts");

my $space = $config->optionspaces->[0];
is(scalar(@_=$space->options), 2, "option space options");
is($space->name, 'foo-enc', "option space name");
is($space->code, 122, "option space code");
is($space->prefix, 'foo', "option space prefix");

my $subnet = $config->subnets->[0];
my $subnet_opt = $subnet->options->[0];
is($subnet->address, "10.0.0.96/27", "subnet address");
is($subnet_opt->name, "domain-name", "subnet option name");
is($subnet_opt->value, "isc.org", "subnet option value");
ok($subnet_opt->quoted, "subnet option is quoted");
is(scalar(@_=$subnet->pools), 3, "three subnet pools found");

my $range = $subnet->pools->[0]->ranges->[0];
is($range->lower, "10.0.0.98/32", "lower pool range");
is($range->upper, "10.0.0.103/32", "upper pool range");

my $host = $config->hosts->[0];
is($host->name, "foo", "host foo found");
is($host->keyvalues->[0]->value, "10.19.83.102", "fixed address found");

my $shared_subnets = $config->sharednetworks->[0]->subnets;
is(int(@$shared_subnets), 2, "shared subnets found");

my $function_body = join("\n", map { "    $_" }
    q(set leasetime = encode-int(lease-time, 32);),
    q(if(1) {),
    q(    set hw_addr   = substring(hardware, 1, 8);),
    q(}),
);

my $function = $config->functions->[0];
ok($function, "function defined");
is($function->name, "commit", "commit function found");
is($function->body, $function_body, "commit body match");


__DATA__
ddns-update-style none;

option space foo;
option foo.bar code 1 = ip-address;
option foo.baz code 2 = ip-address;
option foo-enc code 122 = encapsulate foo;

option domain-name-servers 84.208.20.110, 84.208.20.111;
default-lease-time 86400;
max-lease-time 86400;

on commit {
    set leasetime = encode-int(lease-time, 32);
    if(1) {
        set hw_addr   = substring(hardware, 1, 8);
    }
}

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
    pool {
        range 10.0.0.116 10.0.0.126;
    }
}

shared-network {
    subnet 10.0.0.1 netmask 255.255.255.0 {
    }
    subnet 10.0.1.1 netmask 255.255.255.0 {
    }
}

host foo {
  fixed-address 10.19.83.102;
  hardware ethernet 00:0e:35:d1:27:e3;
}

