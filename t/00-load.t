#!perl -T
use Test::More tests => 1;
BEGIN { use_ok( 'Net::DHCPd' ) }
diag( "Testing Net::DHCPd $Net::DHCPd::VERSION, Perl $], $^X" );
