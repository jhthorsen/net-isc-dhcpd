use Net::ISC::DHCPd::Config;
use Test::More;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 50, 'Parsed 50 lines?');
# need to be able to get at the options under the class
is($config->classes->[0]->options->[0]->name, 'tftp-server-name', 'is class options 0 name == tftp-server-name');
#print $config->generate;
done_testing();


__DATA__
zone example.com
{
    primary 65.50.3.10;
    key secondkey;
}

# test { on the next line..
key box
{
    algorithm hmac-md5;
    secret "...";
};

key secondkey {
    algorithm hmac-md5;
    secret "...";
};

# testing optional semicolon at end
key "thirdkey"
{
    algorithm hmac-md5;
}

class "DlinkATA"
{
    option tftp-server-name "test";
    match if (substring(binary-to-ascii (16,8,":", hardware), 2, 7)= "0:19:5b") or (substring(binary-to-ascii (16,8,":", hardware), 2, 7)= "0:17:9a");
}

class "Cisco IP Phone 7905"
{
    match if (option vendor-class-identifier="Cisco Systems, Inc. IP Phone 7905");
}

class "pxeclients" {
    match if substring(option vendor-class-identifier,0,9) ="PXEClient";
    next-server 10.201.214.90;
}

class "virtual-machines" {
    match if ((substring (hardware, 1, 3) = 00:0c:29)
        or (substring (hardware, 1, 3) = 00:50:56)
        or (substring (option dhcp-client-identifier, 0, 3) = "HPC"));
}

class "consoles"
{
    match pick-first-value (option vendor-class-identifier, host-name);
}
