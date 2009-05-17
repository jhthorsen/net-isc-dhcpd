package Net::DHCPd::Config::Pool;

=head1 NAME

Net::DHCPd::Config::Pool - Pool config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Range;
use Net::DHCPd::Config::KeyValue;

with 'Net::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::DHCPd::Config::Option
    Net::DHCPd::Config::Range
    Net::DHCPd::Config::KeyValue
/);

=head1 OBJECT ATTRIBUTES

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 ranges

A list of parsed L<Net::DHCPd::Config::Range> objects.

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* pool}x },
);

=head1 METHODS

=head2 generate

=cut

sub generate {
    return(
        'pool {',
        shift->generate_config_from_children,
        '}',
    );
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
