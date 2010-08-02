package Net::ISC::DHCPd::Config;

=head1 NAME 

Net::ISC::DHCPd::Config - Parse and create ISC DHCPd config

=head1 SYNOPSIS

    use Net::ISC::DHCPd::Config;

    my $config = Net::ISC::DHCPd::Config->new(
                     file => '/etc/dhcpd3/dhcpd.conf',
                 );

    # parse the config
    $config->parse;

    # parsing includes are lazy
    for my $include ($config->includes) {
        $include->parse;
    }

    print $config->subnets->[0]->dump;
    print $config->includes->[0]->hosts->[0]->dump;
    print $config->generate;

=head1 DESCRIPTION

This class does the role L<Net::ISC::DHCPd::Config::Root>.

=head1 POSSIBLE CONFIG TREE

 Config
  |- Config::Include
  |- Config::Subnet
  |  |- Config::Option
  |  |- Config::Declaration
  |  |- Config::Range
  |  |- Config::Host
  |  |  |- ...
  |  |- Config::Filename
  |  '- Config::Pool
  |     |- Option
  |     |- Range
  |     '- KeyValue
  |
  |- Config::SharedNetwork
  |  |- Config::Subnet
  |  |  |- ...
  |  |- Config::Declaration
  |  '- Config::KeyValue
  |
  |- Config::Group
  |  |- Config::Host
  |  |  |- ...
  |  |- Config::Option
  |  |- Config::Declaration
  |  '- Config::KeyValue
  |
  |- Config::Host
  |  |- Config::Option
  |  |- Config::Filename
  |  |- Config::Declaration
  |  '- Config::KeyValue
  |
  |- Config::OptionSpace
  |  '- Config::OptionSpace::Option
  |
  |- Config::Option
  |- Config::Declaration *
  |- Config::Function
  |- Config::KeyValue
  '- Config::Single      *

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Root';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Function
    Net::ISC::DHCPd::Config::OptionSpace
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::Include
    Net::ISC::DHCPd::Config::KeyValue
/);

sub _build_root { $_[0] }
sub _build_regex { qr{\x00} } # should not be used

=head1 METHODS

=head2 filehandle

This method will be deprecated.

=cut

sub filehandle {
    Carp::cluck('->filehandle is replaced with private attribute _filehandle');
    shift->_filehandle;
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
