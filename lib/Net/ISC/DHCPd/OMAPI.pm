package Net::ISC::DHCPd::OMAPI;

=head1 NAME

Net::ISC::DHCPd::OMAPI - Talk to dhcp server

=cut

use Moose;
use IO::Pty;
use Net::ISC::DHCPd::Config::Host;
use Net::ISC::DHCPd::Config::Group;
#use Net::ISC::DHCPd::Config::Lease;

our $OMSHELL = "omshell";

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

has _connection => (
    is => 'ro',
    lazy_build => 1,
);

# fork omshell and return an IO::Pty object
sub _build__connection  {
    my $self = shift;
    my $pty  = IO::Pty->new;
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

        my $error = sysread $READ, my $errno, 255;

        if($error) {
            $! = $error + 0;
            confess "Could not exec $OMSHELL: $!";
        }

        return $pty;
    }
    else { # child
        close $READ;
        $pty->make_slave_controlling_terminal;
        $slave = $pty->slave;
        $slave->set_raw;

        open STDIN,  "<&". $slave->fileno or confess "Reopen STDIN: $!\n";
        open STDOUT, ">&". $slave->fileno or confess "Reopen STDOUT: $!\n";
        open STDERR, ">&". $slave->fileno or confess "Reopen STDERR: $!\n";

        close $pty;
        close $slave;

        { exec $OMSHELL } # block prevent warning
        print $WRITE int $!;
        die "Could not exec $OMSHELL: $!";
    }
}

# $self->_cmd($cmd);
sub _cmd {
    my $self   = shift;
    my $cmd    = shift;
    my $buffer = q();

    # read/write to socket ++

    return $buffer;
}

=head1 METHODS

=head2 connect

 $bool = $self->connect;

Will open a connection to the dhcp server. Check C<$@> on failure.

=cut

sub connect {
    my $self = shift;

    $@ = q();

    for my $attr (qw/port server key/) {
        $self->_cmd(sprintf "%s %s", $attr, $self->$attr);
        last if($@);
    }

    unless($@) {
        $self->_cmd("connect");
    }

    return $@ ? 0 : 1;
}

=head2 new_object

 $object = $self->new_object($type, %constructor_args);

C<$type> can be group, host, or lease. Will return a new config object.

Example, with C<$type="host">:

 Net::ISC::DHCPd::Config::Host->new(%constructor_args);

=cut

sub new_object {
    my $self  = shift;
    my $type  = shift or return;
    my %args  = @_;
    my $class = "Net::ISC::DHCPd::Config::" .ucfirst(lc $type);

    unless($type =~ /^(?:group|host|lease)$/i) {
        return;
    }

    return $class->new(parent => $self, %args);
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
