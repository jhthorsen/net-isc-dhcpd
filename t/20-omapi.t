#!perl

use strict;
use warnings;
use lib './lib';
use Test::More;

plan skip_all => "cannot run without OMAPI_KEY set" unless($ENV{'OMAPI_KEY'});
plan tests    => 5;

use_ok("Net::ISC::DHCPd::OMAPI");

my $omapi = Net::ISC::DHCPd::OMAPI->new(
                key => $ENV{'OMAPI_KEY'},
            );

is($omapi->server, "127.0.0.1", "got default server");
is($omapi->key, $ENV{'OMAPI_KEY'}, "got server key");
ok($omapi->_fh, "omshell started");
ok($omapi->connect, "connected");

ok($omapi->new_object("lease"), "lease object created");

