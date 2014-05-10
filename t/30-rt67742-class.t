use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 27, 'Parsed 27 lines?');
is($config->classes->[0]->keyvalues->[1]->name, 'next-server', 'is class keyvalue 0 name == next-server');
done_testing();


__DATA__
class "pxeclients" {
    match if substring(option vendor-class-identifier,0,9) ="PXEClient";
    next-server 10.201.214.90;
}

# these newlines are causing match failures
class "virtual-machines" {
    match if ((substring (hardware, 1, 3) = 00:0c:29)
        or (substring (hardware, 1, 3) = 00:50:56)
        or (substring (option dhcp-client-identifier, 0, 3) = "HPC"));
}

class "Cisco IP Phone 7905"
{
    match if (option vendor-class-identifier="Cisco Systems, Inc. IP Phone 7905");
}

class "consoles"
{
    match pick-first-value (option vendor-class-identifier, host-name);
}

class "DlinkATA"
{
    option tftp-server-name "test";
    match if (substring(binary-to-ascii (16,8,":", hardware), 2, 7)= "0:19:5b") or (substring(binary-to-ascii (16,8,":", hardware), 2, 7)= "0:17:9a");
}
