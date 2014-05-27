use Net::ISC::DHCPd::Config;
use Test::More;
use warnings;
use strict;

sub strip_ws {
    $_[0] =~ s/[\s\n\r]+/ /g;
    return $_[0];
}

my $output = 'if substring (option vendor-class-identifier, 0, 4) = "MSFT" { option domain-name "inn.example.com"; } elsif 1 == 0 { } else { foo bar; } # test condition without else if substring (option vendor-class-identifier, 0, 4) = "YUFN" { option domain-name "example.com"; } if 1 == 0 { } elsif 1 == 1 { } else { } ';

my $config = Net::ISC::DHCPd::Config->new(fh => \*DATA);
is($config->parse, 16, 'Parsed 16 lines?');
is(scalar(@_=$config->conditionals), 7, 'config file contains seven conditions');
is(scalar(@_=$config->conditionals->[0]->options), 1, 'one option inside condition');
is($config->conditionals->[0]->type, 'if', 'got "if" condition');
is($config->conditionals->[0]->logic, 'substring (option vendor-class-identifier, 0, 4) = "MSFT"', '...with logic');
is($config->conditionals->[1]->type, 'elsif', 'got "elsif" condition');
is($config->conditionals->[1]->logic, '1 == 0', 'with logic');
is($config->conditionals->[2]->type, 'else', 'got "else" condition');
is($config->conditionals->[3]->type, 'if', 'got "if" condition');
is($config->conditionals->[3]->logic, 'substring (option vendor-class-identifier, 0, 4) = "YUFN"', '...with logic');
is($config->conditionals->[3]->options->[0]->value, 'example.com', 'checking if option value = example.com');
is(strip_ws($config->generate), $output, 'testing conditional generation');

done_testing();


__DATA__
if substring (option vendor-class-identifier, 0, 4) = "MSFT"
      {
         option domain-name "inn.example.com";
      } elsif 1 == 0 {
    }
else {
    foo bar;
}

# test condition without else
if substring (option vendor-class-identifier, 0, 4) = "YUFN" {
        option domain-name
            "example.com";
}

if 1 == 0 {  } elsif 1 == 1 {   } else {    }
