use warnings;
use strict;
use lib qw(lib);
use Test::More;
use Net::ISC::DHCPd::Config;

plan skip_all => 'no t/data/rt71372.conf' unless(-r 't/data/rt71372.conf');
plan tests => 14;

{
    my $config = Net::ISC::DHCPd::Config->new(file => 't/data/rt71372.conf');

    $config->parse;

    print $config->generate;
}
