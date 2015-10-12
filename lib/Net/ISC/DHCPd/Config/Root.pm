package Net::ISC::DHCPd::Config::Root;

=head1 NAME

Net::ISC::DHCPd::Config::Root - Role for root config classes

=head1 DESCRIPTION

This role is applied to root classes, such as L<Net::ISC::DHCPd::Config>
and L<Net::ISC::DHCPd::Config::Include>.

=cut

use Moo::Role;
use Types::Path::Tiny qw ( Path );
use Types::Standard qw( FileHandle Undef );

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 file

This attribute holds a L<Types::Path::Tiny> object representing
path to a config file. Default value is "/etc/dhcp3/dhcpd.conf".

=head2 parent

This attribute is different from L<Net::ISC::DHCPd::Config::Role/parent>:
It holds an undefined value, which is used to indicate that this object
is the top node in the tree. See L<Net::ISC::DHCPd::Config::Include>
if you want a different behavior.

=cut

has parent => (
    is => 'lazy',
    lazy_build => 1,
    isa => Undef,
);

sub _build_parent { undef };

has fh => (
    is => 'rw',
    isa => FileHandle,
    required => 0,
);

has file => (
    is => 'rw',
    isa => Path,
    coerce => 1,
    default => sub { 'etc/dhcp3/dhcpd.conf' },
);

=head1 METHODS

=head2 generate

Will use L<Net::ISC::DHCPd::Config::Role/generate_config_from_children>
to convert the object graph into text.

=cut

sub generate {
    shift->generate_config_from_children ."\n";
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
