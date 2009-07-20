package Net::ISC::DHCPd::Process;

=head1 NAME

Net::ISC::DHCPd::Process

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

    return bless $args, $class;
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

See L<Net::ISC::DHCPd>.

=cut

1;
