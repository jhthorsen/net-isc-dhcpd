#!perl

use strict;
use warnings;
use lib 'lib';
use File::Temp;
use Net::ISC::DHCPd;
use Test::More;

plan tests => 13;

my $binary = 't/data/dhcpd3';
my $pid_file = File::Temp->new;
my $isc = Net::ISC::DHCPd->new(
              binary => $binary,
              pidfile => "$pid_file",
              config => { file => 't/data/dhcpd.conf' },
              leases => { file => 't/data/dhcpd.leases' },
          );

is($isc->binary, $binary, 'binary is set');
is($isc->status, 'stopped', 'process is stopped');
ok($isc->test('config'), 'mock config is valid') or diag $isc->errstr;
ok($isc->test('leases'), 'mock leases is valid') or diag $isc->errstr;

$isc->leases->file('/fooooooooooooooooooooooooooooooo');
ok(!$isc->test('leases'), 'mock leases is now invalid') or diag $isc->errstr;
like($isc->errstr, qr{Invalid leases file}, 'script output "Invalid leases file"');

ok($self->
ok($isc->start, 'server got started');
