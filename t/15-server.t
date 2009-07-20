#!perl

use strict;
use warnings;
use lib 'lib';
use Test::More tests => 6;

use_ok("Net::ISC::DHCPd");

my $isc = Net::ISC::DHCPd->new(binary => 'foo');

eval { $isc->process };
like($@, qr{cannot be build}i, "process cannot be build");
ok($isc->process({}), "process set by hash");
is($isc->status, "stopped", "process is stopped");
ok($isc->test('config'), "config is valid") or diag $isc->errstr;
ok($isc->test('leases'), "leases is valid") or diag $isc->errstr;
