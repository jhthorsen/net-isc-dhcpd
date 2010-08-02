package Net::ISC::DHCPd::Config::Host;

=head1 NAME

Net::ISC::DHCPd::Config::Host - Host config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::Filename
    Net::ISC::DHCPd::Config::KeyValue
/);

=head1 ATTRIBUTES

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::Option> objects.

=head2 filenames

A list of parsed L<Net::ISC::DHCPd::Config::Filename> objects.

Should only be one item in this list.

=head2 name

 $string = $self->name;

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

sub _build_regex { qr{^ \s* host \s (\S+)}x }

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role::captured_to_args()>.

=cut

sub captured_to_args {
    return { name => $_[1] };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role::generate()>.

=cut

sub generate {
    my $self = shift;

    return(
        'host ' .$self->name .' {',
        $self->generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
