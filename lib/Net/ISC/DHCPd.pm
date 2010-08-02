package Net::ISC::DHCPd;

=head1 NAME 

Net::ISC::DHCPd - Interacts with ISC DHCPd

=head1 VERSION

0.0801

=head1 SYNOPSIS

 my $dhcpd = Net::ISC::DHCPd->new(
                 config => { file => "path/to/config" },
                 leases => { file => "path/to/leases" },
                 omapi => { ... },
             );

See tests for more documentation.

=cut

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Class qw(File);
use Net::ISC::DHCPd::Process;
use Net::ISC::DHCPd::Types ':all';
use File::Temp;
use Path::Class::Dir;

our $VERSION = '0.0801';

=head1 ATTRIBUTES

=head2 config

 $config_obj = $self->config
 $bool = $self->has_config;

Instance of L<Net::ISC::DHCPd::Config> class.

=cut

has config => (
    is => 'ro',
    isa => ConfigObject,
    coerce => 1,
    lazy_build => 1,
);

*_build_config = sub { _build_child_obj(Config => @_) };

=head2 leases

 $leases_obj = $self->leases
 $bool = $self->has_leases;

Instance of L<Net::ISC::DHCPd::Leases> class.

=cut

has leases => (
    is => 'ro',
    isa => LeasesObject,
    coerce => 1,
    lazy_build => 1,
);

*_build_leases = sub { _build_child_obj(Leases => @_) };

=head2 omapi

 $omapi_obj = $self->omapi;
 $bool = $self->has_omapi;

Instance of L<Net::ISC::DHCPd::OMAPI> class.

=cut

has omapi => (
    is => 'ro',
    isa => OMAPIObject,
    coerce => 1,
    lazy_build => 1,
);

*_build_omapi = sub { _build_child_obj(OMAPI => @_) };

=head2 binary

 $path_to_binary = $self->binary;

Default: "dhcpd3"

=cut

has binary => (
    is => 'ro',
    isa => 'Str',
    default => 'dhcpd3',
);

=head2 pidfile

 $path_class_object = $self->pidfile;

Default: /var/run/dhcp3-server/dhcpd.pid

=cut

has pidfile => (
    is => 'ro',
    isa => File,
    default => sub {
        Path::Class::File->new('', 'var', 'run', 'dhcp3-server', 'dhcpd.pid');
    },
);

=head2 process

 $proc_obj = $self->process;
 $self->process($proc_obj);
 $self->process(\%args);
 $self->has_process;
 $self->clear_process;

The object holding the dhcpd process.

=cut

has process => (
    is => 'rw',
    isa => ProcessObject,
    coerce => 1,
    lazy_build => 1,
);

sub _build_process {
    confess 'process() cannot be build. Usage: $self->process($process_obj)';
}

=head2 errstr

 $string = $self->errstr;

Holds the last know error.

=cut

has errstr => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

=head1 METHODS

=head2 start

 $bool = $self->start($args);

Will start the dhcpd server, as long as there is no existing process.

C<$args>:

 {
   user       || getpwuid $<
   group      || getgrgid $<
   interfaces || ""
 }

Returns:

 1     => OK
 0     => Already running
 undef => Failed. Check errstr()

TODO: Enable it to start the server as a differnet user/group.

=cut

sub start {
    my $self = shift;
    my $args = shift || {};
    my($user, $group);

    if($self->has_process and $self->process->kill(0)) {
        $self->errstr('allready running');
        return 0;
    }

    $user  = $args->{'user'}  || getpwuid $<;
    $group = $args->{'group'} || getgrgid $<;
    $args  = [
        '-f', # foreground
        '-d', # log to STDERR
        '-cf' => $self->config->file,
        '-lf' => $self->leases->file,
        '-pf' => $self->pidfile,
        $args->{'interfaces'} || q(),
    ];

    $user  = scalar(getpwnam $user);
    $group = scalar(getgrnam $group);

    MAKE_DIR:
    for my $file ($self->config->file, $self->leases->file, $self->pidfile) {
        my $dir = $file->dir;
        next if -d $dir;

        unless(eval { $dir->mkpath }) {
            $self->errstr($@);
            return;
        }

        unless(chown $user, $group, $dir) {
            $self->errstr("could not chown($user, $group $dir): $!");
            return;
        }
    }

    $self->process({
        program => $self->binary,
        args    => $args,
        user    => $user,
        group   => $group,
        start   => 1,
    });

    return $self->process ? 1 : undef;
}

=head2 stop

 $bool = $self->stop;

Return:

 1:     OK
 undef: Failed. Check errstr()

=cut

sub stop {
    my $self = shift;

    unless($self->has_process) {
        $self->errstr("no such process");
        return undef;
    }

    unless($self->process->kill('TERM')) {
        $self->errstr("Could not send signal to process");
        return undef;
    }

    return 1;
}

=head2 restart

 $bool = $self->restart;

Return:

 1     => OK
 undef => Failed. Check errstr()

=cut

sub restart {
    my $self = shift;
    my $proc;
    
    if($self->has_process and !$self->stop) {
        return undef;
    }
    unless($self->start) {
        return undef;
    }

    return 1;
}

=head2 status

 $string = $self->status;

Returns the status of the DHCPd server:

 stopped
 running

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

=head2 test

 $bool = $self->test("config");
 $bool = $self->test("leases");

Will test either config or leases file.

 1:     OK
 undef: Failed. Check errstr()

=cut

sub test {
    my $self = shift;
    my $what = shift || q();
    my $exit;

    if($what eq 'config') {
        my $tmp = File::Temp->new;
        print $tmp $self->config->generate;
        $exit = $self->_run('-t', '-cf', $tmp->filename);
    }
    elsif($what eq 'leases') {
        $exit = $self->_run('-t', '-lf', $self->leases->file);
    }
    else {
        $self->errstr('Invalid argument');
        return;
    }

    if($exit and $exit == -1) {
        $self->errstr($!);
        return;
    }
    elsif($exit) {
        $self->errstr($exit >> 8);
        return;
    }

    return 1;
}

sub _run {
    my $self = shift;
    my @args = @_;
    my $exit;

    local *OLDERR;
    local *OLDOUT;
    open OLDERR, ">&", \*STDERR;
    open OLDOUT, ">&", \*STDOUT;
    close STDERR;
    close STDOUT;

    $exit = system $self->binary, @args;

    open STDERR, ">&", \*OLDERR;
    open STDOUT, ">&", \*OLDOUT;

    return $exit;
}

# used from attributes
sub _build_child_obj {
    my $type = shift;
    my $self = shift;
    my $args = shift || {};

    eval "require Net::ISC::DHCPd::$type" or confess $@;

    return "Net::ISC::DHCPd::$type"->new($args);
}

=head1 BUGS

Please report any bugs or feature requests to
C<bug-net-isc-dhcpd at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-ISC-DHCPd>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jan Henning Thorsen, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

Jan Henning Thorsen, C<< <jhthorsen at cpan.org> >>

=head1 CONTRIBUTORS

Nito Martinez

Alexey Illarionov

Patrick

napetrov

=cut

1;
