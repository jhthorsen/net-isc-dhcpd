use inc::Module::Install;

name     q(Net-ISC-DHCPd);
all_from q(lib/Net/ISC/DHCPd.pm);

requires q(Moose)                     => 0.80;
requires q(NetAddr::IP)               => 4.0;
requires q(File::Path)                => 2.0;
requires q(IO::Pty)                   => 1.0;
requires q(POE::Filter::DHCPd::Lease) => 0.04;

test_requires q(Test::More) => 0;
test_requires q(Test::Pod)  => 0;

auto_install;
WriteAll;
