package Net::DHCPd::Config::Filename;

=head1 NAME

Net::DHCPd::Config::Filename - Filename config parameter

=head1 DESCRIPTION

See L<Net::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 file

 $string = $self->file;

=cut

has file => (
    is => 'rw',
    isa => 'Str',
);

=head2 regex

=cut

has '+regex' => (
    default => sub { qr{^\s* filename \s (\S+) ;}x },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { file => $_[1] };
}

=head1 generate

=cut

sub generate {
    return sprintf q(filename %s;), shift->name;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
