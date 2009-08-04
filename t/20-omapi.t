#!perl

use strict;
use warnings;
use lib './lib';
use Test::More;

plan skip_all => "cannot run without OMAPI_KEY set" unless($ENV{'OMAPI_KEY'});
plan tests    => 14;

BEGIN {
    *Net::ISC::DHCPd::OMAPI::_DEBUG = sub { 1 };
}

use_ok("Net::ISC::DHCPd::OMAPI");

my $omapi = Net::ISC::DHCPd::OMAPI->new(
                key => $ENV{'OMAPI_KEY'},
            );
my $lease;

is($omapi->server, "127.0.0.1", "got default server");
is($omapi->key, $ENV{'OMAPI_KEY'}, "got server key");
ok($omapi->_fh, "omshell started");
ok($omapi->connect, "connected");

ok($lease = $omapi->new_object("lease"), "new lease object created");
ok(!$lease->hardware_address, "hardware_address is not set");
ok($lease->ip_address("10.19.83.200"), "ip_address attr set");
ok($lease->read, "lease read from server");
ok($lease->hardware_address, "got hardware_address from server");

ok($omapi->disconnect, "disconnected from server");
ok($omapi->connect, "re-connected");

# test shutdown
SKIP: {
    skip "restart of server is disabled", 2 if 1;
    ok(my $ctrl = $omapi->new_object("control"), "new control object created");
    ok($ctrl->shutdown_server, "server is shut down");
}

