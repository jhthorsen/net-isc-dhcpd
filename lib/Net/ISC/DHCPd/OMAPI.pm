package Net::ISC::DHCPd::OMAPI;

=head1 NAME

Net::ISC::DHCPd::OMAPI - Talk to a dhcp server

=head1 DESCRIPTION

This module provides an API to query and possible change the ISC DHCPd
server. The module use OMAPI (Object Management API) which does not
require the server to be restarted for changes to apply.

OMAPI is simply a communications mechanism that allows you to manipulate
objects, which is stored in the dhcpd.leases file.

See subclasses for more information about the different objects you can
manipulate:
L<Net::ISC::DHCPd::OMAPI::Failover>,
L<Net::ISC::DHCPd::OMAPI::Group>,
L<Net::ISC::DHCPd::OMAPI::Host>,
and L<Net::ISC::DHCPd::OMAPI::Lease>.

=head1 NOTE

To enable debug output, execute this chunk of code before loading the module:

 BEGIN { Net::ISC::DHCPd::OMAPI::_DEBUG = sub { 1 } }

=cut

use Moose;
use IO::Pty;
use Time::HiRes qw/usleep/;
use Net::ISC::DHCPd::OMAPI::Control;
use Net::ISC::DHCPd::OMAPI::Failover;
use Net::ISC::DHCPd::OMAPI::Group;
use Net::ISC::DHCPd::OMAPI::Host;
use Net::ISC::DHCPd::OMAPI::Lease;

BEGIN {
    unless(__PACKAGE__->meta->has_method('_DEBUG')) {
        __PACKAGE__->meta->add_method(_DEBUG => sub { 1 });
    }
}

our $OMSHELL = 'omshell';

=head1 ATTRIBUTES

=head2 server

 $str = $self->server;

Returns the server address. Default is 127.0.0.1.

=cut

has server => (
    is => 'ro',
    isa => 'Str',
    default => '127.0.0.1',
);

=head2 port

 $int = $self->port;

Returns the server port. Default is 7911.

=cut

has port => (
    is => 'ro',
    isa => 'Int',
    default => 7911,
);

=head2 key

 $str = $self->key;

Returns the server key: "$name $secret".

=cut

has key => (
    is => 'ro',
    isa => 'Str',
    default => '',
);

=head2 errstr

 $str = $self->errstr;

Returns the last known error.

=cut

has errstr => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

# meant for internal usage
has _fh => (
    is => 'ro',
    lazy => 1,
    builder => '_build__fh',
    clearer => '_clear__fh',
);

has _pid => (
    is => 'rw',
    isa => 'Int',
);

# fork omshell and return an IO::Pty object
sub _build__fh  {
    my $self = shift;
    my $pty = IO::Pty->new;
    my($pid, $slave);

    pipe my $READ, my $WRITE or confess $!;
    select +(select($WRITE), $|++)[0]; # autoflush

    $pid = fork;

    if(!defined $pid) { # failed
        $@ = $!;
        return;
    }
    elsif($pid) { # parent
        close $WRITE;
        $pty->close_slave;
        $pty->set_raw;
        $self->_pid($pid);

        if(my $error = sysread $READ, my $errno, 255) {
            $! = $errno + 0;
            confess "Could not exec $OMSHELL: $!";
        }
        if(!defined $pty->sysread(my $buffer, 2048)) {
            return;
        }

        return $pty;
    }
    else { # child
        close $READ;
        $pty->make_slave_controlling_terminal;
        $slave = $pty->slave;
        $slave->set_raw;

        open STDIN,  '<&'. $slave->fileno or confess "Reopen STDIN: $!";
        open STDOUT, '>&'. $slave->fileno or confess "Reopen STDOUT: $!";
        open STDERR, '>&'. $slave->fileno or confess "Reopen STDERR: $!";

        { exec $OMSHELL } # block prevent warning
        print $WRITE int $!;
        confess "Could not exec $OMSHELL: $!";
    }
}

# $self->_cmd($cmd);
sub _cmd {
    my $self = shift;
    my $cmd = shift;
    my $pty = $self->_fh;
    my $out = q();
    my $end_time;

    print STDERR "\$ $cmd\n" if _DEBUG;

    unless(defined $pty->syswrite("$cmd\n")) {
        $self->errstr($!);
        return;
    }

    $end_time = time + 10;

    BUFFER:
    while(time < $end_time) {
        if(defined $pty->sysread(my $tmp, 1024)) {
            $out .= $tmp;
            $out =~ s/>\s$// and last BUFFER;
        }
        else {
            $self->errstr($!);
            return;
        }
    }

    $out =~ s/^>\s//;

    print STDERR $out if _DEBUG;

    return $out;
}

=head1 METHODS

=head2 connect

 $bool = $self->connect;

Will open a connection to the dhcp server. Check C<$@> on failure.

=cut

sub connect {
    my $self = shift;
    my $buffer;

    $self->errstr('');

    for my $attr (qw/port server key/) {
        $buffer = $self->_cmd(sprintf '%s %s', $attr, $self->$attr);
        last unless(defined $buffer);
    }

    if($self->errstr) {
        return;
    }
    unless($buffer = $self->_cmd('connect')) {
        return;
    }
    unless($buffer =~ /obj:\s+/) {
        $self->errstr($buffer);
        return;
    }

    return 1;
}

=head2 disconnect

 $bool = $self->disconnect;

Will disconnect from the server.

=cut

sub disconnect {
    my $self = shift;
    my $retries = 10;

    while($retries--) {
        kill 15, $self->_pid;
        usleep 2e3;
        if(kill 0, $self->_pid) {
            $retries = 1; # make sure it's true
            last;
        }
    }

    unless($retries) {
        return;
    }

    $self->_clear__fh;

    return 1;
}

=head2 new_object

 $object = $self->new_object($type => %constructor_args);

C<$type> can be "group", "host", or "lease". Will return a new config object.

Example, with C<$type="host">:

 Net::ISC::DHCPd::Config::Host->new(%constructor_args);

=cut

sub new_object {
    my $self = shift;
    my $type = shift or return;
    my %args = @_;
    my $class = 'Net::ISC::DHCPd::OMAPI::' .ucfirst(lc $type);

    unless($type =~ /^(?:control|failover|group|host|lease)$/i) {
        return;
    }

    return $class->new(parent => $self, %args);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
