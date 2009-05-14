package Net::DHCPd::Config::Range;

=head1 NAME

Net::DHCPd::Config::Range - IP range config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=head1 NOTES

L<upper> and L<lower> attributes might change from L<NetAddr::IP> to
plain strings in the future.

=cut

use Moose;
use NetAddr::IP;

with 'Net::DHCPd::Config::Role';

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

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
