#!perl

use warnings;
use strict;
use lib './lib';
use Test::More;
use Net::ISC::DHCPd::Config;

my $config = Net::ISC::DHCPd::Config->new(file => './t/60044/dhcpd.conf');

plan tests => 23;

{
    is(ref $config, "Net::ISC::DHCPd::Config", "config object constructed");
    is($config->parse, 57, "all config lines parsed"); # or BAIL_OUT 'failed to parse config';
    is(scalar(@_=$config->options), 1, "one option");
    is(scalar(@_=$config->keyvalues), 3, "three key values");
    is(scalar(@_=$config->functions), 1, "one function");
    is(scalar(@_=$config->hosts), 1, "one host");
    is(scalar(@_=$config->sharednetworks), 1, "one shared network");
}

SKIP: {
    is(scalar(@_=$config->subnets), 1, "one subnet") or skip 'failed to find subnet', 2;
    my $subnet = $config->subnets->[0];
    is($subnet->address, "10.0.0.96/27", "...subnet address");
    is(scalar(@_=$subnet->pools), 3, "...subnet has three pools");
}

SKIP: {
    is(scalar(@_=$config->optionspaces), 2, "two optionspaces") or skip 'Failed to find optionspaces', 4;
    my $space = $config->optionspaces->[1];
    is(scalar(@_=$space->options), 2, "...option space options");
    is($space->name, undef, "...option space name is undefined");
    is($space->code, undef, "...option space code is undefined");
    is($space->prefix, 'PXE', "...option space prefix is PXE");
}

SKIP: {
    is(scalar(@_=$config->includes), 1, "includes") or skip 'failed to find included file', 3;
    my $included = $config->includes->[0];
    like($included->file, qr{foo-included.conf}, 'foo-included.conf got included');
    is($included->parse, 17, 'included file got parsed');
    is(scalar(@_=$included->conditions), 3, 'included file contains three conditions');
    is(scalar(@_=$included->hosts), 1, 'included file contains one host');
    is(scalar(@_=$included->conditions->[0]->options), 1, 'one option inside condition');
    is($included->conditions->[0]->type, 'if', 'got "if" condition');
    is($included->conditions->[0]->logic, 'substring (option vendor-class-identifier, 0, 4) = "MSFT"', '...with logic');

    is($included->conditions->[1]->type, 'elsif', 'got "elsif" condition');
    is($included->conditions->[2]->type, 'else', 'got "else" condition');
}
