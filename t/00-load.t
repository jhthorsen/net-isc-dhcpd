use Test::More tests => 3;
BEGIN { use_ok( 'Net::DHCPd' ) }
BEGIN { use_ok( 'Net::DHCPd::Config' ) }
BEGIN { use_ok( 'Net::DHCPd::Leases' ) }
diag( "Testing Net::DHCPd $Net::DHCPd::VERSION, Perl $], $^X" );
