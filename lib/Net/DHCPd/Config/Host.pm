package Net::DHCPd::Config::Host;

=head1 NAME

Net::DHCPd::Config::Host - Host config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Filename;
use Net::DHCPd::Config::KeyValue;

with 'Net::DHCPd::Config::Role';

__PACKAGE__->create_children(qw/
    Net::DHCPd::Config::Option
    Net::DHCPd::Config::Filename
    Net::DHCPd::Config::KeyValue
/);

=head1 OBJECT ATTRIBUTES

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 filenames

A list of parsed L<Net::DHCPd::Config::Filename> objects.

Should only be one item in this list.

=head2 name

 $string = $self->name;

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^ \s* host \s (\S+)}x },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { name => $_[1] };
}

=head2 generate

=cut

sub generate {
    my $self = shift;

    return(
        sprintf('host %s {', $self->name),
        $self->generate_config_from_children,
        "}",
    );
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
