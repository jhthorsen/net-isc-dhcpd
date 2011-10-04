package Net::ISC::DHCPd::Config::SharedNetwork;

=head1 NAME

Net::ISC::DHCPd::Config::SharedNetwork - Shared-network config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce one of the
blocks below, dependent on L</name> is set or not.
    
    shared-network $name_attribute_value {
        $keyvalues_attribute_value
        $subnets_attribute_value
    }

    shared-network {
        $keyvalues_attribute_value
        $subnets_attribute_value
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 ATTRIBUTES

=head2 subnets

A list of parsed L<Net::ISC::DHCPd::Config::Subnet> objects.

=head2 keyvalues

A list of parsed L<Net::ISC::DHCPd::Config::KeyValue> objects.

=head2 name

Holds a string representing the name of this shared network.
Will be omitted if it contains an empty string.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

sub _build_regex { qr{^\s* shared-network \W* (\w*)}x }

=head1 METHODS

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        'shared-network ' .($self->name ? $self->name . ' ' : '') . '{',
        $self->_generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
