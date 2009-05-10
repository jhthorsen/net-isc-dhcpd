package Net::DHCPd::Config;

=head1 NAME 

Net::DHCPd::Config - Parse and create ISC DHCPd config

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

has '+_children' => (
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
