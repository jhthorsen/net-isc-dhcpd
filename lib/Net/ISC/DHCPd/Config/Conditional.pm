package Net::ISC::DHCPd::Config::Conditional;

=head1 NAME

Net::ISC::DHCPd::Config::Conditional - if, elsif and/or else config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    if option dhcp-user-class = "accounting" {
    }
    elsif option dhcp-user-class = "sales" {
    }
    else {
    }

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Group
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);


=head1 ATTRIBUTES

=head2 type

=cut

has type => (
    is => 'ro',
    isa => 'Str',
);

=head2 logic

=cut

has logic => (
    is => 'ro',
    isa => 'Str',
);

sub _build_regex { qr/^ \s* (if|elsif|else) (.*?)(\s+\{|$) /x }

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    my($self, $type, $logic) = @_;

    $logic =~ s/^\s+|\s+$//g;

    return {
        type => $type,
        logic => $logic,
    };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        $self->logic ? sprintf('%s %s {', $self->type, $self->logic) : $self->type .' {',
        $self->generate_config_from_children,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
