package Net::ISC::DHCPd::Config::Event;

=head1 NAME

Net::ISC::DHCPd::Config::Event - Event config parameters

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    on $name_attribute_value {
        option_attribute;
        keyvalue_attribute;
        if conditional {
        }
    }

An example of this might look something like this:

    on commit { log(info, concat("global commit: ", option dhcp6.client-id)); }
    on expiry { log(info, concat("global expiry: ", option dhcp6.client-id)); }
    on release { log(info, concat("global release: ", option dhcp6.client-id)); }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;
with 'Net::ISC::DHCPd::Config::Role';

use Net::ISC::DHCPd::Config;

=head1 ATTRIBUTES

=head2 children

See L<Net::ISC::DHCPd::Config::Role/children>.

=cut

sub children {
    return Net::ISC::DHCPd::Config::children();
}
__PACKAGE__->create_children(__PACKAGE__->children());


=head2 name

This attribute holds a plain string, representing the name
of the function. Example: "commit".

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);


=head2 regex

See L<Net::ISC::DHCPd::Config::Role/regex>.

=cut

our $regex = qr{^\s* on \s+ (\w+)}x;

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { name => $_[0] }
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        'on ' .$self->name .' {',
        $self->_generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut
__PACKAGE__->meta->make_immutable;
1;
