#!perl

use strict;
use warnings;
use lib 'lib';
use Test::More tests => 7;

use_ok("Net::ISC::DHCPd");

my $binary = './t/data/dhcpd3';
my $isc = Net::ISC::DHCPd->new(
              binary => $binary,
              -leases => {
                  file => './t/data/dhcpd.leases',
              },
          );

eval { $isc->process };
like($@, qr{cannot be build}i, "process cannot be build");
is($isc->binary, $binary, "binary is set");
is($isc->status, "stopped", "process is stopped");
ok($isc->process({}), "process set by hash");
ok($isc->test('config'), "mock config is valid") or diag $isc->errstr;
ok($isc->test('leases'), "mock leases is valid") or diag $isc->errstr;
