use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;
use strict;

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 26, 'Parsed 26 lines?');
is(scalar(@{$config->groups}), 4, 'Checking number of groups found');
is($config->groups->[2]->hosts->[1]->name, 'box3-2', 'Checking random host name');
is($config->groups->[3]->keyvalues->[0]->name, 'next-server', 'Checking if next-server is first keyvalue');

# I should note that I found that nested hosts break this.  It's an invalid
# config anyway, but it's not caught and shown as a parse error.  I think this
# is because the second host entry is treated as a keyvalue or block.
# it's seeing the opening brace as part of the (.*) capture and it doesn't see
# the close brace since it's on another line.

# here is a broken example:
# group { next-server 192.168.0.2; host box1 { host
# box1-2 {option host-name "box1-2"; hardware ethernet 66:55:44:33:22:11;
# fixed-address 192.168.0.2; } } }

# so the worst thing we can do is silently generate a bad config.  I consider
# this our failure even though it's garbage-in garbage-out.  Moving away from
# KeyValue to a point where we parse almost everything would allow us to fail
# this properly.

# because of KeyValue and Block I think you could type a letter to your
# parents and it would consider it a valid config as long as it ended with a
# semi-colon.  Not ideal, but again, make sure the input config passes dhcpd
# validation.

done_testing();


__DATA__
option space foo;  option foo.bar code 1 = ip-address; option host-name "test host name"; option
domain-name-servers 192.168.1.5;
group { next-server 192.168.0.2; host box1 { option host-name "box1" } host box1-2 {option host-name "box1-2"; hardware ethernet 66:55:44:33:22:11; fixed-address 192.168.0.2; } }

group "2" { next-server
   192.168.0.3;
   host box2-1 { }
   host box2-2 {option host-name "box 2"; hardware
   ethernet 66:55:44:33:22:11; fixed-address 192.168.0.3;
   }
} group "3" { next-server
   192.168.0.4;
   # a comment would be nice too
   host box3 {option host-name "box 4"; hardware ethernet 66:55:44:33:22:11; fixed-address 192.168.0.4;
   } host box3-2 { }
}

# totally ordinary stuff here
group {
   next-server 192.168.0.5;
   host box4 {
       option host-name "box 4";
       hardware ethernet 66:55:44:33:22:11;
       fixed-address 192.168.0.2;
   }
}
