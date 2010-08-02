package Net::ISC::DHCPd::Config::Option;

=head1 NAME

Net::ISC::DHCPd::Config::Option - Option config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 name

 $string = $self->name;

Name of the option.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 value

 $string = $self->value;

Value of the option.

=cut

has value => (
    is => 'ro',
    isa => 'Str',
);

=head2 quoted

 $bool = $self->quoted;

This flag tells if the option value should be quoted or not.

=cut

has quoted => (
    is => 'ro',
    isa => 'Bool',
);

sub _build_regex { qr{^\s* option \s (\S+) \s (.*) ;}x }

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role::captured_to_args()>.

=cut

sub captured_to_args {
    my $self   = shift;
    my $name   = shift;
    my $value  = shift;
    my $quoted = 0;

    $quoted = 1 if($value =~ s/^"(.*)"$/$1/g);

    return {
        name   => $name,
        value  => $value,
        quoted => $quoted,
    };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role::generate()>.

=cut

sub generate {
    my $self = shift;
    my $format = $self->quoted ? qq(option %s "%s";) : qq(option %s %s;);

    return sprintf $format, $self->name, $self->value;
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
