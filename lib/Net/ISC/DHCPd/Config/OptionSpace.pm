package Net::ISC::DHCPd::Config::OptionSpace;

=head1 NAME

Net::ISC::DHCPd::Config::OptionSpace - Optionspace config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::OptionSpace::Option
/);

=head1 OBJECT ATTRIBUTES

=head2 options

A list of parsed L<Net::ISC::DHCPd::Config::OptionSpace::Option> objects.

=cut

=head2 name

 $string = $self->name;

Name of the option namespace.

=cut

has name => (
    is => 'rw',
    isa => 'Str',
);

=head2 code

 $dhcp_option_code = $self->code

DHCP option number/code.

=cut

has code => (
    is => 'rw',
    isa => 'Int',
);

=head2 prefix

Human readable prefix of all child
L<Net::ISC::DHCPd::Config::OptionsSpace::Option> objects.

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

=cut

sub captured_to_args {
    return { prefix => $_[1] }
}

=head2 captured_endpoint

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

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
