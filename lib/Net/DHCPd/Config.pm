package Net::DHCPd::Config;

=head1 NAME 

Net::DHCPd::Config - Parse and create ISC DHCPd config

=cut

use Moose;
use Net::DHCPd::Config::Subnet;
use Net::DHCPd::Config::Host;
use Net::DHCPd::Config::Option;

our $CONFIG_FILE = "/etc/dhcp3/dhcpd.conf";

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
    is => 'ro',
    default => sub {
        my $self = shift;
        my $file = $self->file or return;
        open(my $FH, "<", $file) or return;
        $self->filehandle($FH);
    },
);

=head2 children

=cut

has '+_children' => (
    default => sub { 
        shift->create_children(qw/
            Net::DHCPd::Config::Subnet
            Net::DHCPd::Config::Host
            Net::DHCPd::Config::Option
        /);
    },
);

=head1 METHODS

=head2 new

 $obj = $self->new(...);

=cut

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
