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

# option foo-enc code 122 = encapsulate foo;
my $ENCAPSULATE_RE = qr{option (\S+) code (\d+) = encapsulate (\S+)\s*;};

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

=head1 METHODS

=head2 slurp

=cut

sub slurp {
    my($self, $line) = @_;
    my $prefix = $self->prefix;

    #option space foo; <--- already captured
    #option foo.bar code 1 = ip-address;
    #option foo.baz code 2 = ip-address;
    #option foo-enc code 122 = encapsulate foo;

    if($line =~ /(\w+)\s*/) {
        if($line =~ $ENCAPSULATE_RE) {
            confess "encapsulate $3 does not match option space $prefix" if($3 ne $prefix);
            $self->name($1);
            $self->code($2);
        }
        elsif($line =~ /option $prefix\./) {
            return 'children';
        }
        else {
            return 'backtrack';
        }
    }

    return 'next';
}

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { prefix => $_[1] }
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        sprintf('option space %s;', $self->prefix),
        $self->generate_config_from_children,
        $self->name ? (sprintf 'option %s code %i = encapsulate %s;',
            $self->name,
            $self->code,
            $self->prefix,
        ) : (),
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
