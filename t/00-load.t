use Test::More tests => 16;
BEGIN { use_ok( 'Net::DHCPd' ) }
BEGIN { use_ok( 'Net::DHCPd::Config' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Role' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Filename' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Function' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Group' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Host' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::KeyValue' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Option' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::OptionSpace' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::OptionSpace::Option' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Pool' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Range' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::SharedNetwork' ) }
BEGIN { use_ok( 'Net::DHCPd::Config::Subnet' ) }
BEGIN { use_ok( 'Net::DHCPd::Leases' ) }
diag( "Testing Net::DHCPd $Net::DHCPd::VERSION, Perl $], $^X" );
