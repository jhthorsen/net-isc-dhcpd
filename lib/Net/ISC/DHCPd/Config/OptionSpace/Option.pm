package Net::ISC::DHCPd::Config::OptionSpace::Option;

=head1 NAME

Net::ISC::DHCPd::Config::OptionSpace::Option - Optionspace config param data

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce one of the
lines below, dependent on L</quoted>.

    option $parent_prefix_attribute_value.$name_attribute_value \
        code $code_attribute_value = $value_attribute_value;

    option $parent_prefix_attribute_value.$name_attribute_value \
        code $code_attribute_value = "$value_attribute_value";


=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 name

Human readable name of this option, without parent name prefix

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 code

Computer readable code for this option.

=cut

has code => (
    is => 'ro',
    isa => 'Int',
);

=head2 value

Value of the option, as a string.

=cut

has value => (
    is => 'ro',
    isa => 'Str',
);

=head2 quoted

This flag tells if the option value should be quoted or not.

=cut

has quoted => (
    is => 'ro',
    isa => 'Bool',
);

sub _build_regex {
    qr{^\s* option \s (\S+)\.(\S+) \s code \s (\d+) \s = \s (.*) ;}x;
}

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    my $self   = shift;
    my $prefix = shift;
    my $name   = shift;
    my $code   = shift;
    my $value  = shift;
    my $quoted = 0;

    $quoted = 1 if($value =~ s/^"(.*)"$/$1/g);

    return {
        name   => $name,
        code   => $code,
        value  => $value,
        quoted => $quoted,
    };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return sprintf('option %s.%s code %i = %s;',
        $self->parent->prefix,
        $self->name,
        $self->code,
        $self->value,
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
