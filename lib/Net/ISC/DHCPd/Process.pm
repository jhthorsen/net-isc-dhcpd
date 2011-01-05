package Net::ISC::DHCPd::Process;

=head1 NAME

Net::ISC::DHCPd::Process - Default process class

=head1 DESCRIPTION

=cut

use Path::Class::Dir;
use Moose;

with 'Net::ISC::DHCPd::Process::Role';

=head1 METHODS

=head2 start

    $bool = $self->start(\%args);

Will start the dhcpd server, as long as there is no existing process.
See L</SYNOPSIS> for example. C<%args> can have C<user>, C<group> and
C<interfaces> which all points to strings. This method returns and
integer or undef: "1" means "started". "0" means "already running"
and C<undef> means failed to start the server. Check L</errstr> on
failure.

TODO: Enable it to start the server as a different user/group.

=cut

sub start {
    my $self = shift;
    my $args = shift || {};
    my($user, $group, $uid, $gid);

    if($self->process->kill(0)) {
        $self->errstr('already running');
        return 0;
    }

    $user = $self->user;
    $group = $self->group;
    $args = [
        '-cf' => $self->config->file,
        '-lf' => $self->leases->file,
        '-pf' => $self->pidfile,
        $args->{'interfaces'} || q(),
    ];

    $uid = getpwnam $user || $<;
    $gid = getgrnam $group || $(;

    MAKE_DIR:
    for my $file ($self->config->file, $self->leases->file, $self->pidfile) {
        my $dir = $file->dir;
        next if -d $dir;

        unless(eval { $dir->mkpath }) {
            $self->errstr($@);
            return;
        }

        unless(chown $uid, $gid, $dir) {
            $self->errstr("could not chown($user, $group $dir): $!");
            return;
        }
    }

    return $self->process->start;
}


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
