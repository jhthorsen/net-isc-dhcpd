package Net::ISC::DHCPd::Config::OptionSpace;

=head1 NAME

Net::ISC::DHCPd::Config::OptionSpace - Optionspace config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    option space $prefix_attribute_value;
    $options_attribute_value
    option $name_attribute_value code \
        $code_attribute_value = encapsulate $prefix_attribute_value;
 
=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::OptionSpace::Option
/);

=head1 ATTRIBUTES

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::OptionSpace::Option> objects.

=head2 name

Name of the option namespace as a string.

=cut

has name => (
    is => 'rw',
    isa => 'Str',
);

=head2 code

DHCP option number/code as an int.

=cut

has code => (
    is => 'rw',
    isa => 'Int',
);

=head2 prefix

Human readable prefix of all child
L<Net::ISC::DHCPd::Config::OptionSpace::Option> objects.

=cut

has prefix => (
    is => 'ro',
    isa => 'Str',
);

sub _build_regex { qr{^\s* option \s space \s (.*) ;}x }

sub _build_endpoint {
    qr{^
        \s* option \s (\S+)
        \s  code \s (\d+) \s =
        \s  encapsulate \s (\S+) ;
    }x;
}

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { prefix => $_[1] }
}

=head2 captured_endpoint

See L<Net::ISC::DHCPd::Config::Role/captured_endpoint>.

=cut

sub captured_endpoint {
    my $self = shift;

    unless($_[2] and $_[2] eq $self->prefix) {
        confess "prefix does not match '$_[2]'";
    }

    $self->name($_[0]);
    $self->code($_[1]);
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        sprintf('option space %s;', $self->prefix),
        $self->generate_config_from_children,
        sprintf('option %s code %i = encapsulate %s;',
            $self->name,
            $self->code,
            $self->prefix,
        ),
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
