package Net::ISC::DHCPd;

=head1 NAME 

Net::ISC::DHCPd - Interacts with ISC DHCPd

=head1 SYNOPSIS

 my $dhcpd = Net::ISC::DHCPd->new(
                 -config => { file => "path/to/config" },
                 -leases => { file => "path/to/leases" },
             );

See tests for more documentation.

=cut

use Moose;
use Moose::Util::TypeConstraints;
use File::Basename;
use File::Path;
use File::Temp;
use Net::ISC::DHCPd::Process;

=head1 VARIABLES

=head2 $PROCESS_CLASS

The class that should spawn the L<process> object. Needs to support
the minimum api of L<Net::ISC::DHCPd::Process>.

=cut

our $VERSION = "0.01";
our $PROCESS_CLASS = "Net::ISC::DHCPd::Process";

subtype NetISCDHCPdProcObject => as 'Object';
coerce NetISCDHCPdProcObject => (
    from HashRef => via { $PROCESS_CLASS->new(%$_) },
);

=head1 OBJECT ATTRIBUTES

=head2 config

 $config_obj = $self->config

Default: L<Net::ISC::DHCPd::Config>.

=cut

has config => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::ISC::DHCPd::Config',
    default => sub {
        eval "require Net::ISC::DHCPd::Config" or confess $@;
        Net::ISC::DHCPd::Config->new;
    },
);

=head2 leases

 $leases_obj = $self->leases

Default: L<Net::ISC::DHCPd::Leases>.

=cut

has leases => (
    is => 'ro',
    lazy => 1,
    isa => 'Net::ISC::DHCPd::Leases',
    default => sub {
        eval "require Net::ISC::DHCPd::Leases" or confess $@;
        Net::ISC::DHCPd::Leases->new;
    },
);

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

 $path_to_pidfile = $self->pidfile;

Default: /var/run/dhcp3-server/dhcpd.pid

=cut

has pidfile => (
    is => 'ro',
    isa => 'Str',
    default => '/var/run/dhcp3-server/dhcpd.pid',
);

=head2 process

 $proc_obj = $self->process;
 $self->process($proc_obj);
 $self->process(\%args); # will use $PROCESS_CLASS to create object
 $self->has_process;
 $self->clear_process;

The object holding the dhcpd process.

=cut

has process => (
    is => 'rw',
    isa => 'NetISCDHCPdProcObject',
    lazy_build => 1,
    coerce => 1,
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

=head2 BUILD

Takes extra '-foo' arguments to C<new()> and appends the values to
the appropriate attribute.

Example:

 $self = $class->new(
   -config => {
     file => "/foo/bar.conf",
   },
 );

Will result in:

 $self = $class->new;
 $self->config->file("/foo/bar.conf");

=cut

sub BUILD {
    my $self = shift;
    my $args = shift;

    for my $attr (%$args) {
        next unless(ref $args->{$attr} eq 'HASH');
        next unless($attr =~ s/^-//);
        next unless($self->has_attribute($attr));

        for my $key (%$attr) {
            $self->$attr->$key($attr->{$key});
        }
    }
}

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
        my $dir = dirname $file;
        next if -d $dir;

        eval {
            File::Path::mkpath($dir);
            1;
        } or do {
            $self->errstr("could not mkpath($dir): $@");
            return;
        };

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
        $self->errstr($? >> 8);
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

    $exit = system $self->binary, @_;

    open STDERR, ">&", \*OLDERR;
    open STDOUT, ">&", \*OLDOUT;

    return $exit;
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

=cut

1;
