package Net::DHCPd;

=head1 NAME 

Net::DHCPd - Interacts with ISC DHCPd

=head1 SYNOPSIS

 my $dhcpd = Net::DHCPd->new(
                 config_file => "path/to/config",
                 leases_file => "path/to/leases",
             );

 my $config = $dhcpd->config;

 $config->parse;

 for my $child ($config->children) {
    # ...
 }

=cut

use Moose;

our $VERSION = "0.01";

=head1 OBJECT ATTRIBUTES

=head2 config

Holds a DHCPd config object.

Default: L<Net::DHCPd::Config>.

=cut

has config => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::DHCPd::Config',
    default => sub {
        eval "require Net::DHCPd::Config" or confess $@;
        Net::DHCPd::Config->new;
    },
);

=head2 leases

Holds a DHCPd leases object.

Default: L<Net::DHCPd::Leases>.

=cut

has leases => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::DHCPd::Leases',
    default => sub {
        eval "require Net::DHCPd::Leases" or confess $@;
        Net::DHCPd::Leases->new;
    },
);

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
