package Net::DHCPd::Config::Filename;

=head1 NAME

Net::DHCPd::Config::Filename - Filename config parameter

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

See L<Net::DHCPd::Config::Role>.

=cut

has '+regex' => (
    default => sub { qr{^\s* filename \s (\S+) ;}x },
);

=head1 METHODS

=head2 captured_to_args

See L<Net::DHCPd::Config::Role>.

=cut

sub captured_to_args {
    return { filename => $_[1] };
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
