# consider merging this with braces.t

use lib './lib';
use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;
use strict;
use Data::Dumper;

my $data_pos = tell DATA;
my $input = do { local($/); <DATA> };
seek DATA, $data_pos, 0;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 16, 'Parsed xx lines?');
is($config->generate, $input, 'Does input match output?');

done_testing();

__DATA__
group {
   filename "fai/pxelinux.0";
   on commit {
        execute("/usr/local/sbin/dhcpd-keytab", host-decl-name);
   }
   on release { log(info, concat("global release: ", option dhcp6.client-id)); }

   host workstation00 {hardware ethernet A1:B2:C3:D4:E5:03; fixed-address 10.1.0.50; ddns-hostname workstation00;}
   host compute00 {hardware ethernet A1:B2:C3:D4:E5:04; fixed-address 10.1.0.154; ddns-hostname compute04;}
   host compute01 {hardware ethernet A1:B2:C3:D4:E5:05; fixed-address 10.1.0.155; ddns-hostname compute05;}
}

group {
   filename "fai/pxelinux.0";
   host diskless00 {hardware ethernet A1:B2:C3:D4:E5:00; fixed-address 10.1.0.246; ddns-hostname diskless00;}
   host diskless01 {hardware ethernet A1:B2:C3:D4:E5:01; fixed-address 10.1.0.247; ddns-hostname diskless01;}
}
