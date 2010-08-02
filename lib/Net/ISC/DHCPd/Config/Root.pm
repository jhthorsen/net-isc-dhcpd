package Net::ISC::DHCPd::Config::Root;

=head1 NAME

Net::ISC::DHCPd::Config::Root - Role to parse and create ISC DHCPd config

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

use Moose::Role;
use MooseX::Types::Path::Class qw(File);

with 'Net::ISC::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 file

 $str = $self->file;

Holds the path to the config file.

=cut

has file => (
    is => 'rw',
    isa => File,
    coerce => 1,
    default => sub { Path::Class::File->new('', 'etc', 'dhcp3', 'dhcpd.conf') },
);

=head2 parent

 $self = $self->parent;

This override L<Net::ISC::DHCPd::Config::Role::parent> attribute
with an undef value. This is used to see that we are at the top level.

=cut

has parent => (
    is => 'ro',
    isa => 'Undef|Net::ISC::DHCPd::Config', # TODO: Need to remove union
    default => sub { undef },
);

=head2 subnets

List of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 hosts

List of parsed L<Net::ISC::DHCPd::Config::Host> objects.

=head2 options

List of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=head1 METHODS

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
