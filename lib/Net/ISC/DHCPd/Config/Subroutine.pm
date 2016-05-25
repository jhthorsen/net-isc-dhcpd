package Net::ISC::DHCPd::Config::Subroutine;

=head1 NAME

Net::ISC::DHCPd::Config::Subroutine - Misc option config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce one of the
lines below, dependent on L</quoted>.

    functionname( <anything here> ) ;

This doesn't concern itself with recursive functions.  It will capture the
outermost function and ignore the inner one.  We would need to do recursive
parsing to get the inner functions, and we would need to be much more aware of
ISC innards.


=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 name

Name of the option - See L</DESCRIPTION> for details.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 value

Value of the option - See L</DESCRIPTION> for details.

=cut

has body => (
    is => 'ro',
    isa => 'Str',
);

=head2 regex

See L<Net::ISC::DHCPd::Config::Role/regex>.

=cut

our $regex = qr{^\s* ([\w-]+\s*) \((.*)\) ;}x;

=head1 METHODS

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    my ($name, $body) = @_;

    return {
        name   => $name,
        body   => $body,
    };
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self  = shift;
    return sprintf '%s(%s);', $self->name, $self->body;
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut
__PACKAGE__->meta->make_immutable;
1;
