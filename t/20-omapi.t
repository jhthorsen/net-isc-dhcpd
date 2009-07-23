#!perl

use strict;
use warnings;
use lib './lib';
use Test::More;

plan skip_all => "cannot run without OMAPI_KEY set" unless($ENV{'OMAPI_KEY'});
plan tests    => 7;

BEGIN {
    *Net::ISC::DHCPd::OMAPI::_DEBUG = sub { 0 };
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

ok($lease = $omapi->new_object("lease"), "lease object created");
ok($lease->set(ip_address => "10.19.83.200"), "set ip-address");


