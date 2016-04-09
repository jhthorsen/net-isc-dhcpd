#!perl
use warnings;
use strict;
use lib q(lib);
use Test::More;

my @text = <DATA>;
for(@text) { chomp; }

use Net::ISC::DHCPd::Config::FailoverPeer;

my $failoverpeer = Net::ISC::DHCPd::Config::FailoverPeer->new(
    name => 'testgroup',
    type => 'primary',
    address => '198.51.100.1',
    peer_address => '198.51.100.2',
    port => 519,
    peer_port => 520,
    max_response_delay => 60,
    max_unacked_updates => 10,
    mclt => 3600,
    split => 128,
    lb_max_seconds => 3,
);

my @test = split(/\n/,$failoverpeer->generate());

is_deeply([sort @test], [sort @text], "config generated");
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
