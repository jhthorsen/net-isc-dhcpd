package Net::ISC::DHCPd::Config::Function;

=head1 NAME

Net::ISC::DHCPd::Config::Function - Function config parameters

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    on $name_attribute_value {
        $body_attribute_value
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

# TODO: Should probably be a role instead...
extends 'Net::ISC::DHCPd::Config::Block';

=head1 ATTRIBUTES

=head2 name

This attribute holds a plain string, representing the name
of the function. Example: "commit".

=head2 body

The body text of the function, without trailing newline at end.
The function body is not parsed, so the containing text can be
anything.

=cut

=head2 regex

See L<Net::ISC::DHCPd::Config::Role/regex>.

=cut

our $regex = qr{^\s* on \s+ (\w+)}x;

=head1 METHODS

=head2 append_body

Should probably be deprecated.

=head2 prepend_body

Should probably be deprecated.

=head2 body_length

Should probably be deprecated.

=cut

sub append_body { push @{ shift->_body }, @_ }
sub prepend_body { unshift @{ shift->_body }, @_ }
sub body_length { length $_[0]->body }

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
        $self->body,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut
__PACKAGE__->meta->make_immutable;
1;
