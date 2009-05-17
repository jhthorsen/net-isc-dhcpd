#!perl

use warnings;
use strict;
use Benchmark;
use NetAddr::IP;
use Test::More;

my $count = 1;
my $text = do { local $/; <DATA> };

plan tests => 1 + 2 * $count;

use_ok("Net::DHCPd::Config");

my $time = timeit($count, sub {
    my $config = Net::DHCPd::Config->new;

    is(ref $config, "Net::DHCPd::Config", "config object constructed");

    $config->add_keyvalue(
        name => 'ddns-update-style',
        value => 'none',
    );
    $config->add_optionspace(
        name => 'foo-enc',
        prefix => 'foo',
        code => 122,
        options => [
            Net::DHCPd::Config::OptionSpace::Option->new(
                name => 'bar',
                code => 1,
                value => 'ip-address',
            ),
        ],
    );
    $config->add_function(
        name => "commit",
        body => "    set leasetime = encode-int(lease-time, 32);\n",
    );
    $config->add_subnet(
        address => NetAddr::IP->new('10.0.0.96/27'),
        options => [
            Net::DHCPd::Config::Option->new(
                name => 'routers',
                value => '10.0.0.97',
            ),
        ],
        pools => [
            Net::DHCPd::Config::Pool->new(
                ranges => [
                    Net::DHCPd::Config::Range->new(
                        upper => NetAddr::IP->new("10.0.0.116"),
                        lower => NetAddr::IP->new("10.0.0.126"),
                    ),
                ],
            ),
        ],
    );
    $config->add_host(
        name => 'foo',
        keyvalues => [
            Net::DHCPd::Config::KeyValue->new(
                name => 'fixed-address',
                value => '10.19.83.102',
            ),
        ],
    );

    #print $config->generate;

    is($config->generate, $text, "config generated");
});

diag($count .": " .timestr($time));

__DATA__
subnet 10.0.0.96 netmask 255.255.255.224 {
    option routers 10.0.0.97;
    pool {
        range 10.0.0.126 10.0.0.116;
    }
}
host foo {
    fixed-address 10.19.83.102;
}
on commit {
    set leasetime = encode-int(lease-time, 32);

}
option space foo;
    option foo.bar code 1 = ip-address;
option foo-enc code 122 = encapsulate foo;
ddns-update-style none;
