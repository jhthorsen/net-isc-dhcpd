use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 23, 'Parsed 23 lines?');
is($config->keys->[0]->name, 'box', 'is key 0 name = box?');
is($config->keys->[1]->name, 'secondkey', 'is key 1 name = secondkey?');
is($config->keys->[2]->name, 'thirdkey', 'is key 2 name = thirdkey?');
is($config->keys->[1]->secret, '...', 'is key 1 secret = ...?');
is($config->keys->[2]->algorithm, 'hmac-md5', 'is key 2 algorithm = hmac-md5?');
is($config->zones->[0]->name, 'example.com', 'is zone 0 name = example.com?');
is($config->zones->[0]->key, 'secondkey', 'is zone 0 key = secondkey?');
is($config->zones->[0]->primary, '10.0.0.5', 'is zone 0 primary = 10.0.0.5?');
done_testing();


__DATA__
zone example.com
{
    primary 10.0.0.5;
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
