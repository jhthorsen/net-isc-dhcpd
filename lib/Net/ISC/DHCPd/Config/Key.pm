package Net::ISC::DHCPd::Config::Key;

=head1 NAME

Net::ISC::DHCPd::Config::Key - Server key

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce the block below:

    $name_attribute_value $value_attribute_value;

    key "$name" {
        algorithm $algorithm;
        secret "$secret";
    };

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

has [qw/ name algorithm secret /] => (
    is => 'rw', # TODO: WILL PROBABLY CHANGE!
    isa => 'Str',
);

sub _build_children { [undef] }
sub _build_regex { qr{^\s* key \s (")?(\S+)\1 }x }

=head1 METHODS

=head2 slurp

This method is used by L<Net::ISC::DHCPd::Config::Role/parse>, and will
slurp the content of the function, instead of trying to parse the
statements.

=cut

sub slurp {
    my($self, $line) = @_;

    return 'last' if($line =~ /^\s*}/);
    $self->algorithm($1) if($line =~ /algorithm \s+ (\S+);/x);
    $self->secret($2) if($line =~ /secret \s+ ("?)(\S+)\1;/x);
    return 'next';
}

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

    return(
        sprintf('key "%s" {', $self->name),
        $self->algorithm ? (sprintf '    algorithm %s;', $self->algorithm) : (),
        $self->secret ? (sprintf '    secret "%s";', $self->secret) : (),
        '};', # TODO: should this really be here?
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
