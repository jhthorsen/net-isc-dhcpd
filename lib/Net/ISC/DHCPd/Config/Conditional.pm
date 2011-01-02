package Net::ISC::DHCPd::Config::Subnet;

=head1 NAME

Net::ISC::DHCPd::Config::Subnet - Subnet config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    if option dhcp-user-class = "accounting" {
    }
    elsif option dhcp-user-class = "sales" {
    }
    else {
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=cut

has children => (
    is => 'ro',
    isa => 'NetAddr::IP',
);

=head2 regex

See L<Net::ISC::DHCPd::Config/regex>.

=cut

sub _build_regex { qr{^ \s* subnet \s (\S+) \s netmask \s (\S+) }x }

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { address => NetAddr::IP->new(join "/", @_[1,2]) };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;
    my $net = $self->address;

    return(
        'subnet ' .$net->addr .' netmask ' .$net->mask .' {',
        $self->generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
