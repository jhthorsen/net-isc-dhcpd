package Net::DHCPd;

=head1 NAME 

Net::DHCPd - Interacts with ISC DHCPd

=cut

use Moose;

our $VERSION = "0.01";

=head1 OBJECT ATTRIBUTES

=head2 config

=cut

has config => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::DHCPd::Config',
    default => sub { Net::DHCPd::Config->new },
);

=head2 leases

=cut

has leases => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::DHCPd::Leases',
    default => sub { Net::DHCPd::Leases->new },
);

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
