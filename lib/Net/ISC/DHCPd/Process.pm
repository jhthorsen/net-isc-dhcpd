package Net::ISC::DHCPd::Process;

=head1 NAME

Net::ISC::DHCPd::Process - Default process class

=head1 DESCRIPTION

=cut

use Moose;

with 'Net::ISC::DHCPd::Process::Role';

=head1 METHODS

=head2 start

=cut

sub start {
    my $self = shift;
    my $child_exit = system { $self->name } @{ $self->args };

    # pid?

    return $child_exit ? 0 : 1;
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
