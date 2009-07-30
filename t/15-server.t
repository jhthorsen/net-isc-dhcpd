#!perl

use strict;
use warnings;
use lib 'lib';
use Test::More tests => 11;

use_ok("Net::ISC::DHCPd");
use_ok("Net::ISC::DHCPd::Process");

ok(!Net::ISC::DHCPd::Process->can('kill'), "cannot kill()");
ok(setup_process_class(), "applied MyProcessRole") or diag $@;
ok(Net::ISC::DHCPd::Process->can('kill'), "can kill()");

my $binary = './t/data/dhcpd3';
my $isc = Net::ISC::DHCPd->new(
              binary => $binary,
              leases => {
                  file => './t/data/dhcpd.leases',
              },
          );

eval { $isc->process };
like($@, qr{cannot be build}i, "process attribute cannot be build");
is($isc->binary, $binary, "binary is set");
is($isc->status, "stopped", "process is stopped");
ok($isc->process({}), "process set by hash");
ok($isc->test('config'), "mock config is valid") or diag $isc->errstr;
ok($isc->test('leases'), "mock leases is valid") or diag $isc->errstr;

sub setup_process_class {
    eval qq[
        package MyProcessRole;
        use Moose::Role;
        use Net::ISC::DHCPd::Process;

        sub kill { }

        MyProcessRole->meta->apply( Net::ISC::DHCPd::Process->meta );

        1;
    ];
}

