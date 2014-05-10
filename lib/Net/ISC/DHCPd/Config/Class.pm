package Net::ISC::DHCPd::Config::Class;

=head1 NAME

Net::ISC::DHCPd::Config::Class;

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce the block below:

    class "$name" {
        ...
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 name

Name of the key - See L</DESCRIPTION> for details.

=head2 algorithm

=head2 secret

=cut

has [qw/ name /] => (
    is => 'rw',
    isa => 'Str',
);

# match will get treated as a KeyValue
__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);

sub _build_regex { qr{^\s* class \s (")?(.*?)(\1|$) }x }

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { name => $_[2] }; # $_[1] == quote or empty string
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;
    return sprintf('class "%s" {', $self->name), $self->_generate_config_from_children, '}';
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
