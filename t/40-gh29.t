use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;
use strict;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA, , file => "./t/data/dhcpd.conf");
is($config->parse, 9, 'Parsed config file');

my $include = $config->subnets->[0]->includes->[0];
is($include->parse, 6, 'Parsed included file (subnet)');

$include = $config->subnet6s->[0]->includes->[0];
is($include->parse, 6, 'Parsed included file (subnet6)');

done_testing();

__DATA__
subnet 10.11.21.0 netmask 255.255.255.224 {
        option routers 10.11.21.221;
        include "foo-included.conf";
}

subnet6 3ffe:501:ffff:100::/64 {
    include "foo-included.conf";
}

