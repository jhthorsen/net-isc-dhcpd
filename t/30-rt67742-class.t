use Net::ISC::DHCPd::Config;
use Test::More;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 10, 'Parsed 10 lines?');
# need to be able to get at the options under the class
#is($config->blocks->[0]->options->[0]->name, 'next-server', 'is class options 0 name == next-server');
# something is happening to indention that we probably need to figure out
# I think the Block statements don't grab the indention properly
# print $config->generate;
done_testing();


__DATA__
class "pxeclients" {
    match if substring(option vendor-class-identifier,0,9) ="PXEClient";
    next-server 10.201.214.90;
}

class "virtual-machines" {
    match if ((substring (hardware, 1, 3) = 00:0c:29)
        or (substring (hardware, 1, 3) = 00:50:56)
        or (substring (option dhcp-client-identifier, 0, 3) = "HPC"));
}
