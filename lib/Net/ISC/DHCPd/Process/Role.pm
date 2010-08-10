package Net::ISC::DHCPd::Process::Role;

=head1 NAME

Net::ISC::DHCPd::Process::Role - Role for processes

=head1 DESCRIPTION

This role is subject for change. Feedback is very much welcome!

=cut

use Time::HiRes qw/usleep/;
use Moose::Role;

requires 'start';

=head1 ATTRIBUTES

=head2 name

This attribute holds the name/path of the process to start.
It is required when constructing the object.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_group',
    required => 1,
);

=head2 args

This attribute holds an array-ref of all the command line options to
be passed to the process.

=cut

has args => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 user

    $str = $self->group;
    $bool = $self->has_group;
 
Holds the username (as string) which this process should run as.

=cut

has user => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_group',
);

=head2 group

    $str = $self->group;
    $bool = $self->has_group;
 
Holds the group (as string) which this process should run as.

=cut

has group => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_group',
);

=head2 pid

    $int = $self->pid;
    $bool = $self->has_pid;
    $self->clear_pid;

Holds the process id of the child process.

=cut

has pid => (
    is => 'ro',
    isa => 'Int',
    writer => '_set_pid',
    predicate => 'has_pid',
    clearer => 'clear_pid',
);

=head1 METHODS

=head2 stop

Will use L</kill> to stop the child process.

=cut

sub stop {
    my $self = shift;

    for my $signal (qw/ TERM QUIT INT KILL /) {
        $self->kill($signal) or return -1;
        usleep 1e5; # need to sleep so process gets some time to end
        $self->kill(0) or return 1;
    }

    return;
}

=head2 kill

Use the internal C<kill()> to signal the process.

=cut

sub kill {
    my($self, $signal) = @_;
    return kill $self->pid, $signal;
}

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
