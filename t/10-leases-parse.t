#!perl

use warnings;
use strict;
use lib './lib';
use Benchmark;
use Test::More;

my $count  = $ENV{'COUNT'} || 1;
my $leases = "./t/data/dhcpd.leases";
my $lines  = 104;

plan tests => 1 + 10 * $count;

use_ok("Net::ISC::DHCPd::Leases");

my $time = timeit($count, sub {
    my $leases = Net::ISC::DHCPd::Leases->new(file => $leases);
    my $lease;

    is(ref $leases, "Net::ISC::DHCPd::Leases", "leases object constructed");
    is($leases->parse, $lines, "all leases lines parsed");
    is(@{ $leases->leases }, 10, "got leases");

    $lease = $leases->leases->[0];

    is($lease->starts, 1215970952, "lease->0 starts");
    is($lease->ends, 1216057352, "lease->0 ends");
    is($lease->binding, "free", "lease->0 binding");
    is($lease->hw_ethernet, "0015582f83bc", "lease->0 hw_ethernet");
    is($lease->hostname, undef, "lease->0 hostname");
    is($lease->circuit_id, undef, "lease->0 circuit id");
    is($lease->remote_id, undef, "lease->0 remote id");
});

diag(($lines * $count) .": " .timestr($time));

