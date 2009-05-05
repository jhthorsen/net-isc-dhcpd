package Net::DHCPd::Config;

=head1 NAME 

Net::DHCPd::Config - Parse and create ISC DHCPd config

=cut

use Moose;

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

=head2 children

=cut

has '+children' => (
    default => sub {
        [
            Net::DHCPd::Config::Subnet->new,
            Net::DHCPd::Config::Host->new,
            Net::DHCPd::Config::Option->new,
        ],
    },
);

=head1 METHODS

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    $self->root($self);
    $self->parent($self);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
