#!perl

use strict;
use warnings;
use lib './lib';
use Test::More;
use Benchmark;
use File::Temp;


plan skip_all => 'set environment variable DHCP_TORTURE_TEST to run this test' unless ($ENV{'DHCP_TORTURE_TEST'});

my $count  = $ENV{'COUNT'} || 1;
plan tests => 1 + 3 * $count;

use_ok("Net::ISC::DHCPd::Config");

my $fh = File::Temp->new();
my $data = do {local $/;<DATA>};

for(1..20000) {
    print $fh $data;
}

my $time = timeit($count, sub {

    seek $fh, 0, 0;
    my $config = Net::ISC::DHCPd::Config->new(fh => $fh);
    $config->parse();

    is(scalar(@_=$config->subnets), 20000, 'Are there 20000 distinct subnets?');
    is(scalar(@_=$config->groups), 20000, 'Are there 20000 distinct groups?');
    is(scalar(@_=$config->includes), 20000, 'Are there 20000 distinct includes?');
});

__DATA__

# this file doesn't have to exist.  Just testing the parser
include "test.conf";

subnet 127.0.0.0 netmask 255.255.255.0 {
    pool
    {
        range 127.0.0.1;
    }
}

group "Cats" {

    option root-path "EST";
    dynamic-bootp-lease-length 3600;
    min-lease-time 1800;
    default-lease-time 43200;

    subnet 127.0.0.0 netmask 255.255.255.0 {
        pool
        {
            range 127.0.0.1;
        }
    }

    shared-network "Kittens" {

        subnet 127.1.0.0 netmask 255.255.255.0 {
            pool
            {
                range 127.1.0.1 127.1.0.2;
            }
        }

        subnet 127.2.0.0 netmask 255.255.255.0 {
            pool
            {
                range 127.2.0.1 127.2.0.2;
            }
        }

        host hostything
        {
            hardware ethernet 00:xx:xx:xx:xx:xx;
            fixed-address 127.0.0.1;
        }

    }

}

