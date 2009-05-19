package Net::DHCPd::Config;

=head1 NAME 

Net::DHCPd::Config - Parse and create ISC DHCPd config

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
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::SharedNetwork;
use Net::DHCPd::Config::Function;
use Net::DHCPd::Config::OptionSpace;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::KeyValue;

with 'Net::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::DHCPd::Config::Host
    Net::DHCPd::Config::Subnet
    Net::DHCPd::Config::SharedNetwork
    Net::DHCPd::Config::Function
    Net::DHCPd::Config::OptionSpace
    Net::DHCPd::Config::Option
    Net::DHCPd::Config::KeyValue
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
    default => sub {
        my $self = shift;
        my $file = $self->file or return;
        open(my $FH, "<", $file) or return;
        $self->filehandle($FH);
    },
);

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

List of parsed L<Net::DHCPd::Config::Subnet> objects.

=head2 hosts

List of parsed L<Net::DHCPd::Config::Host> objects.

=head2 options

List of parsed L<Net::DHCPd::Config::Option> objects.

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
