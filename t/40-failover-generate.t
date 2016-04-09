#!perl

use warnings;
use strict;
use lib q(lib);
use Benchmark;
use NetAddr::IP;
use Test::More;

my $text = do { local $/; <DATA> };

use_ok("Net::ISC::DHCPd::Config::FailoverPeer");

my $failoverpeer = Net::ISC::DHCPd::Config::FailoverPeer->new(
    name => 'testgroup',
    type => 'primay',
    address => '198.51.100.1',
    peer_address => '198.51.100.2',
    port => 647,
    peer_port => 647,
    max_response_delay => 60,
    max_unacked_updates => 10,
    mclt => 3600,
    split => 128, 
    lb_max_seconds => 3,
);

 is($failoverpeer->generate(), $text, "config generated");

print $failoverpeer->generate();

done_testing();

__DATA__
failover peer "testgroup" {
    primary;
    address 198.51.100.1;
    peer address 198.51.100.2;
    port 519;
    peer port 520;
    max-response-delay 60;
    max-unacked-updates 10;
    mclt 3600;
    split 128;
    load balance max seconds 3;
}