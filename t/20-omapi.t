#!perl

use strict;
use warnings;
use lib './lib';
use Test::More;

plan skip_all => "cannot run without OMAPI_KEY set" unless($ENV{'OMAPI_KEY'});
plan tests    => 21;

BEGIN { *Net::ISC::DHCPd::OMAPI::_DEBUG = sub { 0 } }
use_ok("Net::ISC::DHCPd::OMAPI");

my $omapi = Net::ISC::DHCPd::OMAPI->new( key => $ENV{'OMAPI_KEY'} );
my($host, $lease);

is($omapi->server, "127.0.0.1", "got default server");
is($omapi->key, $ENV{'OMAPI_KEY'}, "got server key");
ok($omapi->_fh, "omshell started");
ok($omapi->connect, "connected");

ok($host = $omapi->new_object("host"), "new host object created");
ok(!$host->hardware_address, "hardware_address is not set");
ok($host->name("thorslapp"), "name attr set");
is($host->read, 4, "host read from server");
is($host->hardware_address, "00:0e:35:d1:27:e3", "got hardware_address from server");

ok($lease = $omapi->new_object("lease"), "new lease object created");
ok(!$lease->hardware_address, "hardware_address is not set");
ok($lease->ip_address("10.19.83.200"), "ip_address attr set");
is($lease->read, 15, "lease read from server");
is($lease->hardware_address, "00:13:02:b8:a9:1b", "got hardware_address from server");

my $duplicate_host = $omapi->new_object(host => (
                            name => 'thorslapp',
                            hardware_address => '00:0e:35:d1:27:e3',
                            hardware_type => 1,
                            ip_address => '0a:13:53:66',
                        ));

ok($host->remove, 'object removed') or diag $host->errstr;
ok($duplicate_host->write, 'object written') or diag $host->errstr;

ok($omapi->disconnect, "disconnected from server");
ok($omapi->connect, "re-connected");

# test shutdown
SKIP: {
    skip "restart of server is disabled", 2 if 1;
    ok(my $ctrl = $omapi->new_object("control"), "new control object created");
    ok($ctrl->shutdown_server, "server is shut down");
}

