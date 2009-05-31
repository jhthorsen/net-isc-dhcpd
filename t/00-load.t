use Test::More tests => 16;
BEGIN { use_ok( 'Net::ISC::DHCPd' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Role' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Filename' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Function' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Group' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Host' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::KeyValue' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Option' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::OptionSpace' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::OptionSpace::Option' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Pool' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Range' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::SharedNetwork' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Config::Subnet' ) }
BEGIN { use_ok( 'Net::ISC::DHCPd::Leases' ) }
diag( "Testing Net::ISC::DHCPd $Net::ISC::DHCPd::VERSION, Perl $], $^X" );
