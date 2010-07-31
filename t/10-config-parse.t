#!perl

use warnings;
use strict;
use lib './lib';
use Benchmark;
use Test::More;

my $count  = $ENV{'COUNT'} || 1;
my $config = "./t/data/dhcpd.conf";
my $lines  = 51;

plan tests => 1 + 24 * $count;

use_ok("Net::ISC::DHCPd::Config");

my $time = timeit($count, sub {
    my $config = Net::ISC::DHCPd::Config->new(file => $config);

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
});

diag(($lines * $count) .": " .timestr($time));

