#!perl

use warnings;
use strict;
use lib './lib';
use Benchmark;
use Test::More;

my $count  = $ENV{'COUNT'} || 1;
my $lines  = 51;

plan tests => 1 + 34 * $count;

use_ok("Net::ISC::DHCPd::Config");

my $time = timeit($count, sub {
    # we specify a filename so the include statement can figure out the
    # base directory
    my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA, file => "./t/data/dhcpd.conf");

    is(ref $config, "Net::ISC::DHCPd::Config", "config object constructed");
    is($config->parse, $lines, "all config lines parsed") or BAIL_OUT 'failed to parse config';

    is(scalar(@_=$config->keyvalues), 3, "key values");
    is(scalar(@_=$config->optionspaces), 1, "option space");
    is(scalar(@_=$config->options), 1, "options");
    is(scalar(@_=$config->subnets), 1, "subnets");
    is(scalar(@_=$config->hosts), 1, "hosts");
    is(scalar(@_=$config->includes), 1, "includes");

    my $included = $config->includes->[0];
    like($included->file, qr{foo-included.conf}, 'foo-included.conf got included');
    is($included->parse, 6, 'included file got parsed');
    is(scalar(@_=$included->hosts), 1, 'included file contains one host');

    is(scalar(@_=$config->optioncodes), 3, "option code options");
    my $space = $config->optioncodes->[2];
    is($space->name, 'foo-enc', "option space name");
    is($space->code, 122, "option space code");
    is($space->prefix, undef, "option space prefix");

    my $subnet = $config->subnets->[0];
    my $subnet_opt = $subnet->options->[0];
    is($subnet->address, "10.0.0.96/27", "subnet address");
    is($subnet_opt->name, "domain-name", "subnet option name");
    is($subnet_opt->value, "isc.org", "subnet option value");
    ok($subnet_opt->quoted, "subnet option is quoted");
    is(scalar(@_=$subnet->pools), 3, "three subnet pools found");

    is($config->find_subnets({ address => 'foo' }), 0, 'could not find subnets with "foo" as network address');
    is($config->find_subnets({ address => '10.0.0.96/27' }), 1, 'found subnets with "10.0.0.96/27" as network address');
    is($config->remove_subnets({ address => '10.0.0.96/27' }), 1, 'removed subnets with "10.0.0.96/27" as network address');
    is($config->find_subnets({ address => '10.0.0.96/27' }), 0, 'could not find subnets with "10.0.0.96/27" as network address');

    my $range = $subnet->pools->[0]->ranges->[0];
    is($range->lower, "10.0.0.98/32", "lower pool range");
    is($range->upper, "10.0.0.103/32", "upper pool range");

    my $host = $config->hosts->[0];
    is($host->name, "foo", "host foo found");
    is($host->fixedaddresses->[0]->value, "10.19.83.102", "fixed address found");
    is($host->hardwareethernets->[0]->value, '00:0e:35:d1:27:e3', "mac address found");
    ok($host->hardwareethernet eq '00:0e:35:D1:27:E3', "mac address found (case compare)");

    my $shared_subnets = $config->sharednetworks->[0]->subnets;
    is(int(@$shared_subnets), 2, "shared subnets found");

    my $function_body = join("\n",
        q(set leasetime = encode-int(lease-time, 32);),
        q(if(1) {),
        q(    set hw_addr   = substring(hardware, 1, 8);),
        q(}),
    );

    my $function = $config->functions->[0];
    ok($function, "function defined");
    is($function->name, "commit", "commit function found");
    is($function->body, $function_body, "commit body match");
});

diag(($lines * $count) .": " .timestr($time));

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
  filename "pxelinux.0";
}

include "foo-included.conf";
