package Net::ISC::DHCPd::Process::Role;

=head1 NAME

Net::ISC::DHCPd::Process::Role - Role for processes

=head1 DESCRIPTION

This role is subject for change. Feedback is very much welcome!

=cut

use Time::HiRes qw/usleep/;
use MooseX::Types::Path::Class qw(File);
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

=head2 pidfile

This attribute holds a L<Path::Class::File> object to the dhcpd binary.
It is read-only and the default is "/var/run/dhcp3-server/dhcpd.pid".

=cut

has pidfile => (
    is => 'ro',
    isa => File,
    coerce => 1,
    default => sub {
        Path::Class::File->new('', 'var', 'run', 'dhcp3-server', 'dhcpd.pid');
    },
);

=head2 pid

=cut

has pid => (
    is => 'ro',
    isa => 'Int',
    init_arg => undef,
    lazy_build => 1,
);

sub _build_pid {
    open my $PID, '<', $_[0]->pidfile or return 0;
    my $pid = readline $PID or return 0;
    chomp $pid;
    return $pid || 0;
}

=head1 METHODS

=head2 restart

 $bool = $self->restart;

This method will restart a running server or start a stopped server.
A true return value means that the server got started, while false
means it could not be started/restarted. Check L<errstr> or failure.

=cut

sub restart {
    my $self = shift;
    my $proc;
    
    if($self->pid > 0 and !$self->stop) {
        $self->errstr("could not stop server");
        return undef;
    }
    unless($self->start) {
        $self->errstr("could not start server");
        return undef;
    }

    return 1;
}

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

=head2 status

 $str = $self->status;

Returns the status of the DHCPd server: "stopped" or "running".

=cut

sub status {
    my $self = shift;

    if($self->has_process) {
        if($self->process->kill(0)) {
            return "running";
        }
    }

    return "stopped";
}

=head1 BUGS

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
