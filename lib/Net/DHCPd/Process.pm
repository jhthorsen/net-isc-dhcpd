package Net::DHCPd::Process;

=head1 NAME

Net::DHCPd::Process

=cut

use strict;
use warnings;

=head1 METHODS

=head2 new

 $self = $class->new($args)
 $self = $class->new(%args)

Spawns a dhcpd process, running in the background.

Args:

 program
 args
 user
 group

=cut

sub new {
    my $class = shift;
    my $args  = @_ == 1 ? $_[0] : {@_};

    # spawn...

    return;
}

=head2 pid

 $pid = $self->pid

=cut

sub pid {
    return;
}

=head2 kill

 $bool = $self->kill($signal)

=cut

sub kill {
    return;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
