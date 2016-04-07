use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 55, 'Parsed xx lines?');
is($config->failoverpeers->[0]->name, 'failover', '1st failoverpeer = failover');
is($config->failoverpeers->[1]->name, 'failover-partner', '2nd failover name = failover-partner');
is($config->failoverpeers->[2]->name, 'one-line', 'is name for 3rd failover one-line');
is($config->failoverpeers->[3]->name, 'one-line-with-comment', 'is name for 4th failover one-line-with-comment');
is($config->failoverpeers->[1]->type, 'secondary', 'is type for second failover secondary?');
is($config->failoverpeers->[2]->type, undef, 'is type for third failover undef?');
is($config->failoverpeers->[3]->port, 520, '4th failover port 520');
is($config->failoverpeers->[0]->peer_port, 520, 'peer port for first failover 520');
is($config->failoverpeers->[2]->peer_port, 519, 'peer port for third failover 519');
is($config->failoverpeers->[3]->peer_port, 519, 'peer port for 4th failover 519');
is($config->failoverpeers->[3]->max_lease_misbalance, 20, '4th failover max-lease-misbalance 20');
is($config->failoverpeers->[3]->max_lease_ownership, 30, '4th failover max-lease-ownership 30');
is($config->failoverpeers->[3]->min_balance, 20, '4th failover min-balance 20');
is($config->failoverpeers->[3]->max_balance, 300, '4th failover max-balance 300');
is($config->failoverpeers->[3]->auto_partner_down, 30, '4th failover auto-partner-down 30');
is($config->subnets->[0]->pools->[0]->keyvalues->[0]->name, 'failover', 'does the failover peer option work');
done_testing();

__DATA__
failover peer "failover" {
    primary;
    address dhcp-primary.example.com;
    port 519;
    peer address dhcp-secondary.example.com;
    peer port 520;
    max-response-delay 60;
    max-unacked-updates 10;
    mclt 3600;
    split 128;
    load balance max seconds 3;
}

# secondary isn't allowed to have mclt or split.  The parameters should
# otherwise match the primary.
failover peer "failover-partner" {
    secondary;
    address dhcp-secondary.example.com;
    port 520;
    peer address dhcp-primary.example.com;
    peer port 519;
    max-response-delay 60;
    max-unacked-updates 10;
    load balance max seconds 3;
}

failover peer one-line {
    address dhcp-secondary.example.com; port 520; peer address dhcp-primary.example.com; peer port 519; max‐response‐delay 60; max‐unacked‐updates 10; load balance max seconds 3;
}

subnet 10.100.100.0 netmask 255.255.255.0 {

   option domain-name-servers 10.0.0.53;
   option routers 10.100.100.1;
   pool {
       failover peer "failover-partner";
       range 10.100.100.20 10.100.100.254;
   }
}

failover peer one-line-with-comment {
    address dhcp-secondary.example.com; port 520; # need to make; sure this works {}
    peer address dhcp-primary.example.com;
    peer port 519;
    max-response-delay 60;
    max-unacked-updates 10;
    load balance max seconds 3;
    # make sure new statements work
    auto-partner-down 5;
    max-lease-misbalance 20;
    max-lease-ownership 30;
    max-balance 300;
    min-balance 20;
    auto-partner-down 30;
}
