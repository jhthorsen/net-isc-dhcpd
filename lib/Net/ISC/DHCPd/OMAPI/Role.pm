package Net::ISC::DHCPd::OMAPI::Role;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Role - Common api for OMAPI objects

=head1 DESCRIPTION

Changing object attributes will not alter the attributes on server. To do
so, either use L<set()> directly or use L<sync()> after altering attributes.

=cut

use Moose;

=head1 ATTRIBUTES

=head2 parent

 $omapi_obj = $self->parent;

=cut

has parent => (
    is => 'ro',
    isa => 'Net::ISC::DHCPd::OMAPI',
    required => 1,
);

=head1 METHODS

=head2 set

 $bool = $self->set($attribute => $value, ...);

Attribute names are defined in dhcpd(8) and  dhclient(8).

=cut

sub set {
    my $self = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};
    my(@out, $success);

    @out = $self->_cmd(
               ( map { "set $_ = $args->{$_}" } keys %$args ),
               "update", # create?
           );

    # read @out:
    # ip-address = c0:a8:04:32

    if($success) {
        $self->$_($args->{$_}) for(keys %$args);
    }

    return;
}

=head2 unset

 $bool = $self->unset(@attributes);

=cut

sub unset {
    my $self = shift;
    my @attr = @_;
    my(@out, $success);
    
    @out = $self->_cmd((map { "unset $_" } @attr), "update");

    # read @out:
    # ip-address = <null>
    # key = value
    # ...

    if($success) {
        $self->${ \"clear_$_" } for(@attr);
    }

    return;
}

=head2 open

 $int = $self->open;

Will read attributes from server, and return the number of attributes read.

=cut

sub open {
    my $self = shift;
    my $pk   = "foo";
    my(@out, %attr);

    @out = $self->_cmd(
               sprintf("set %s = %s", $pk, $self->$pk),
               "open",
           );

    # read @out:
    # client-hostname = "wendelina"
    # key = value
    # ...

    for my $key (keys %attr) {
        $self->$key($attr{$key});
    }

    return int keys %attr;
}

=head2 remove

 $bool = $self->remove;

=cut

sub remove {
    my $self = shift;
    my $pk   = shift;
    my @out;

    @out = $self->_cmd(
               sprintf("set %s = %s", $pk, $self->$pk),
               "remove",
           );

    for my $attr ($self->meta->get_all_attributes) {
        next unless($attr->has_value('omapi'));
        $self->${ \"clear_" .$attr->name };
    }

    return;
}

=head2 sync

 $bool = $self->sync;

=cut

sub sync {
    my $self = shift;
    my %args;

    for my $attr ($self->meta->get_all_attributes) {
        next unless($attr->has_value('omapi'));
        $args{$attr->name} = $self->${ \$attr->name };
    }

    return $self->set(%args);
}

sub _cmd {
    my $self  = shift;
    my @cmd   = @_;
    my($type) = lc +( ref($self) =~ /::(\w+)$/ );
    my @buffer;

    for my $cmd (qq[new "$type"], @cmd) {
        my $buffer = $self->parent->_cmd($cmd);
        return if($@);
        push @buffer, split /\n\r?/, $buffer;
    }

    return @buffer;
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
