use inc::Module::Install;

name     q(Net-DHCPd);
all_from q(lib/Net/DHCPd.pm);

requires      q(Moose)              => 0;
requires      q(NetAddr::IP)        => 0;
requires      q(File::Path)         => 0;
test_requires q(Test::More)         => 0;
test_requires q(Test::Pod)          => 0;

auto_install;
WriteAll;
