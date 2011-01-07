#!perl

use strict;
use warnings;
use lib 'lib';
use File::Temp;
use Net::ISC::DHCPd;
use Test::More;

plan tests => 5;

my $binary = 't/data/dhcpd3';
my $pid_file = File::Temp->new;
my $dhcpd = Net::ISC::DHCPd->new(
                binary => $binary,
                pidfile => "$pid_file",
                config => { file => 't/data/dhcpd.conf' },
                leases => { file => 't/data/dhcpd.leases' },
           );

is($dhcpd->binary, $binary, 'binary is set');
ok($dhcpd->test('config'), 'mock config is valid') or diag $dhcpd->errstr;
ok($dhcpd->test('leases'), 'mock leases is valid') or diag $dhcpd->errstr;

$dhcpd->leases->file('/fooooooooooooooooooooooooooooooo');
ok(!$dhcpd->test('leases'), 'mock leases is now invalid') or diag $dhcpd->errstr;
like($dhcpd->errstr, qr{Invalid leases file}, 'script output "Invalid leases file"');
