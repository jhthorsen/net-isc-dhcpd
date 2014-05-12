use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 12, 'Parsed 12 lines?');
is($config->groups->[0]->name, 'Hello', 'testing quoted named groups');
is($config->groups->[1]->name, 'not-quoted2', 'named group that is unquoted with dashes and number');
is($config->groups->[2]->name, 'With Spaces', 'testing spaces in name');
ok(defined($config->groups->[3]), 'Do unnamed groups still work?');
done_testing();

__DATA__
group "Hello" {
}

# numbers should work as well as dashes
group not-quoted2 {
}

group "With Spaces" {
}

group {
}
