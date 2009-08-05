package Net::ISC::DHCPd::Process;

=head1 NAME

Net::ISC::DHCPd::Process - Skeleton process class

=head2 USAGE

 package MyProcessRole;
 use Moose;
 use Net::ISC::DHCPd::Process

 has program => ( is => 'rw' );
 has args => ( is => 'rw' );
 has user => ( is => 'rw' );
 has group => ( is => 'rw' );

 after BUILDALL => sub {
   my $self = shift;
   my $args = shift;

   if($args->{'start'}) {
     # spawn process
   }
 };

 sub kill {
   # kill process
 }

 MyProcessRole->meta->apply( Net::ISC::DHCPd::Process->meta );

 1;

=cut

use Moose;

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
 start

=head2 pid

 $pid = $self->pid

=head2 kill

 $bool = $self->kill($signal)

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
