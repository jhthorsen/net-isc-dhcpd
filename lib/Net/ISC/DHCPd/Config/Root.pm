package Net::ISC::DHCPd::Config::Root;

=head1 NAME

Net::ISC::DHCPd::Config::Root - Role to parse and create ISC DHCPd config

=cut

use Moose::Role;
use MooseX::Types::Path::Class qw(File);

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

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

This override L<Net::ISC::DHCPd::Config::Role/parent> attribute
with an undef value. This is used to see that we are at the top level.

=cut

has parent => (
    is => 'ro',
    isa => 'Undef|Net::ISC::DHCPd::Config', # TODO: Need to remove union
    default => sub { undef },
);

=head1 METHODS

=head2 generate

 $config_text = $self->generate;

Will turn object tree into a actual config, which can be written to file.

=cut

sub generate {
    shift->generate_config_from_children ."\n";
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
