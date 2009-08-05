package Net::ISC::DHCPd::Config::Range;

=head1 NAME

Net::ISC::DHCPd::Config::Range - Range config parameter

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=head1 NOTES

L<upper> and L<lower> attributes might change from L<NetAddr::IP> to
plain strings in the future.

=cut

use Moose;
use NetAddr::IP;

with 'Net::ISC::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 upper

 $ip_obj = $self->upper;

Returns undef or a L<NetAddr::IP> object.

=cut

has upper => (
    is => 'ro',
    isa => 'NetAddr::IP',
);

=head2 lower

 $ip_obj = $self->lower;

Returns undef or a L<NetAddr::IP> object.

=cut

has lower => (
    is => 'ro',
    isa => 'NetAddr::IP',
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* range \s (\S+) \s (\S*) ;}x },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return {
        lower => NetAddr::IP->new($_[1]),
        upper => NetAddr::IP->new($_[2]),
    };
}

=head2 generate

=cut

sub generate {
    return sprintf("range %s %s;", $_[0]->lower->addr, $_[0]->upper->addr);
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
