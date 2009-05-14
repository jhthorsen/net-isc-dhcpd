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
  |- Config::Function    *
  |- Config::KeyValue
  '- Config::Single      *

=cut

use Moose;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::OptionSpace;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::KeyValue;

our $CONFIG_FILE = "/etc/dhcp3/dhcpd.conf";
our $DEBUG       = 0;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 file

=cut

has file => (
    is => 'ro',
    isa => 'Str',
    default => $CONFIG_FILE,
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

=head2 children

=cut

has '+children' => (
    default => sub { 
        shift->create_children(qw/
            Net::DHCPd::Config::Subnet
            Net::DHCPd::Config::Host
            Net::DHCPd::Config::OptionSpace
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::KeyValue
        /);
    },
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

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
