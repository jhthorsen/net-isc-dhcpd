#!/usr/bin/env perl

use strict;
use warnings;

unless(eval "use Net::ISC::DHCPd::OMAPI; 1") {
    die "The perl module 'Net::ISC::DHCPd::OMAPI' is required\n";
}
unless(@ARGV) {
    die <<'USAGE';

Information about ISC DHCPd and OMSHELL:
    $ man omshell;

With OMAPI_KEY:
    $ OMAPI_KEY="name secret" check-lease-state.pl ...;

Without OMAPI_KEY:
    $ check-lease-state.pl ...;

"..." can be either mac or ip-address.

USAGE

}

my($omapi, $lease);

$omapi = Net::ISC::DHCPd::OMAPI->new( key => $ENV{'OMAPI_KEY'} );
$omapi->connect or die "Could not connect to server: ", $omapi->errstr, "\n";
$lease = $omapi->new_object('lease');
$lease->hardware_address($ARGV[0]) if($ARGV[0] =~ /:/);
$lease->ip_address($ARGV[0]) if($ARGV[0] =~ /\./);
$lease->read or die "Could not read lease: ", $omapi->errstr, "\n";

print $lease->dump(1);
