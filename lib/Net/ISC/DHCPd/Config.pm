package Net::ISC::DHCPd::Config;

=head1 NAME 

Net::ISC::DHCPd::Config - Parse and create ISC DHCPd config

=head1 POSSIBLE CONFIG TREE

 Config
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
use Net::ISC::DHCPd::Config::Host;
use Net::ISC::DHCPd::Config::Subnet;
use Net::ISC::DHCPd::Config::SharedNetwork;
use Net::ISC::DHCPd::Config::Function;
use Net::ISC::DHCPd::Config::OptionSpace;
use Net::ISC::DHCPd::Config::Option;
use Net::ISC::DHCPd::Config::KeyValue;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Function
    Net::ISC::DHCPd::Config::OptionSpace
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 OBJECT ATTRIBUTES

=head2 file

=cut

has file => (
    is => 'rw',
    isa => 'Str',
    default => '/etc/dhcp3/dhcpd.conf',
);

=head2 filehandle

=cut

has filehandle => (
    is => 'rw',
    lazy_build => 1,
);

sub _build_filehandle {
    my $self = shift;
    my $file = $self->file or confess 'file attribute needs to be set';
    open(my $FH, "<", $file) or confess "cannot open $file: $!";
    $self->filehandle($FH);
}

=head2 root

=cut

has '+root' => (
    default => sub { shift },
);

=head2 parent

=cut

has '+parent' => (
    default => sub { shift },
);

=head2 subnets

List of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 hosts

List of parsed L<Net::ISC::DHCPd::Config::Host> objects.

=head2 options

List of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=head1 METHODS

=head2 new

 $obj = $self->new(...);

=head2 generate

 $config_text = $self->generate;

Will turn object tree into a actual config, which can be written to file.

=cut

sub generate {
    shift->generate_config_from_children ."\n";
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
