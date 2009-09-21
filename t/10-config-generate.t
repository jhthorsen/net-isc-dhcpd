#!perl

use warnings;
use strict;
use lib q(lib);
use Benchmark;
use NetAddr::IP;
use Test::More;

my $count = 1;
my $text = do { local $/; <DATA> };

plan tests => 1 + 2 * $count;

use_ok("Net::ISC::DHCPd::Config");

my $time = timeit($count, sub {
    my $config = Net::ISC::DHCPd::Config->new;

    is(ref $config, "Net::ISC::DHCPd::Config", "config object constructed");

    $config->add_keyvalue(
        name => 'ddns-update-style',
        value => 'none',
    );
    $config->add_optionspace(
        name => 'foo-enc',
        prefix => 'foo',
        code => 122,
        options => [
            Net::ISC::DHCPd::Config::OptionSpace::Option->new(
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
            Net::ISC::DHCPd::Config::Option->new(
                name => 'routers',
                value => '10.0.0.97',
            ),
        ],
        pools => [
            Net::ISC::DHCPd::Config::Pool->new(
                ranges => [
                    Net::ISC::DHCPd::Config::Range->new(
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
            Net::ISC::DHCPd::Config::KeyValue->new(
                name => 'fixed-address',
                value => '10.19.83.102',
            ),
        ],
        filenames => [
            Net::ISC::DHCPd::Config::Filename->new(
                file => 'pxelinux.0',
            ),
        ],
    );

    #print $config->generate;

    is($config->generate, $text, "config generated");
});

diag($count .": " .timestr($time));

__DATA__
ddns-update-style none;
option space foo;
    option foo.bar code 1 = ip-address;
option foo-enc code 122 = encapsulate foo;
on commit {
    set leasetime = encode-int(lease-time, 32);
}
subnet 10.0.0.96 netmask 255.255.255.224 {
    option routers 10.0.0.97;
    pool {
        range 10.0.0.126 10.0.0.116;
    }
}
host foo {
    fixed-address 10.19.83.102;
    filename pxelinux.0;
}
