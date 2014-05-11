use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;
use strict;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 1, 'Parsed 1 lines?');
#printf "Parsed %s lines\n\n", $config->parse; print $config->generate();

done_testing();


__DATA__
group { next-server 192.168.0.2; host box1 { host box2 {option host-name "box2"; hardware ethernet 66:55:44:33:22:11; fixed-address 192.168.0.2; } }
