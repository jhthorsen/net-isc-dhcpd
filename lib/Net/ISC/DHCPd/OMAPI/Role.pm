package Net::ISC::DHCPd::OMAPI::Role;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Role - Common api for OMAPI objects

=head1 DESCRIPTION

Changing object attributes will not alter the attributes on server. To do
so, either use L<set()> directly or use L<write()> after altering attributes.

=cut

use Moose::Role;

requires 'primary';

=head1 ATTRIBUTES

=head2 parent

 $omapi_obj = $self->parent;

=cut

has parent => (
    is => 'ro',
    isa => 'Net::ISC::DHCPd::OMAPI',
    required => 1,
);

=head2 errstr

 $str = $self->errstr;

=cut

has errstr => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

=head1 METHODS

=head2 set

 $bool = $self->set($attribute => $value, ...);

Attribute names are defined in dhcpd(8) and dhclient(8). Only difference
is that "-" is converted to "_" when used with this module. Example:

 $self->set(ip_address => $value);   # correct
 $self->set("ip-address" => $value); # wrong

=cut

sub set {
    my $self = shift;
    my $args = ref $_[0] eq 'HASH' ? $_[0] : {@_};
    my(@cmd, @out, @error);

    for my $attr (keys %$args) {
        my $key = $attr;
        $key =~ s/_/-/g;
        push @cmd, "set $key = $args->{$attr}";
    }

    @out = $self->_cmd(@cmd);

    for my $i (0..@cmd-1) {
        my($match) = ($cmd[$i] =~ /set\s+([\w-]+)\s+=/);

        if($out[$i] =~ /($match)/) {
            my $attr = $1;
            $attr =~ s/-/_/g;
            $self->$attr($args->{$attr}); # update object values
        }
        else {
            push @error, $out[$i];
        }
    }

    if(@error) {
        # need to do stuff with @error...
        return 0;
    }

    $self->_set_primary_value unless(exists $args->{ $self->primary });
    $self->_cmd( $self->read ? "update" : "create" ) or return;

    return 1;
}

around set => \&_around;

=head2 unset

 $bool = $self->unset(@attributes);

Will unset values for an object in DHCP server. See L<set()> for details
about C<@attributes>.

=cut

sub unset {
    my $self = shift;
    my @attr = @_;
    my(@out, $success);
    
    @out = $self->_cmd(map { local $_ = $_; s/_/-/g; "unset $_" } @attr);

    # read @out:
    # ip-address = <null>
    # key = value
    # ...

    if($success) {
        $self->${ \"clear_$_" } for(@attr);
    }

    return;
}

around unset => \&_around;

=head2 remove

 $bool = $self->remove;

=cut

sub remove {
    my $self = shift;
    my $pk   = $self->primary;
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

around remove => \&_around;

=head2 write

 $bool = $self->write;

Will set all attributes on server object.

=cut

sub write {
    my $self = shift;
    my %args;

    for my $attr ($self->meta->get_all_attributes) {
        next unless($attr->has_value('omapi'));
        $args{$attr->name} = $self->${ \$attr->name };
    }

    return $self->set(%args);
}

# wrapper for set(), unset() and remove();
sub _around {
    my $next = shift;
    my $self = shift;
    my $type = lc +(ref($self) =~ /::(\w+)$/)[0];
    my @out;

    @out = $self->_cmd("new $type") or return 0;
    $self->$next(@_)                or return 0;
    @out = $self->_cmd('close')     or return 0;

    return (@out and $out[0] =~ /obj:/) ? 1 : 0;
};

=head2 read 

 $int = $self->read;

Open an object. Returns the number of attributes read. 0 = not in server.

=cut

sub read {
    my $self = shift;
    my($out) = $self->_cmd("open");
    my $n;

    while($out =~ /(\S+)\s=\s(\S+)/g) {
        my($attr, $value) = ($1, $2);
        $attr =~ s/-/_/g;

        if($self->meta->has_attribute($attr)) {
            $self->${ \"_$attr" }($value);
            $n++;
        }
        else {
            warn "$self does not have attribute $attr";
        }
    }

    return $n;
}

# $bool = $self->_set_primary_value;
sub _set_primary_value {
    my $self = shift;
    my $attr = $self->primary;
    my $key  = $attr;

    $key =~ s/_/-/g;

    return $self->_cmd("set $key = $self->$attr");
}

# @buffer = $self->_cmd(@cmd)
# @buffer contains one-to-one output data from @cmd
# $self->errstr is reset each time empty errstr == success
sub _cmd {
    my $self = shift;
    my @cmd  = @_;
    my(@buffer, $head);

    $self->errstr("");

    for my $cmd (@cmd) {
        my $tmp = $self->parent->_cmd($cmd);
        last unless(defined $tmp);
        push @buffer, $tmp;
    }

    if($self->parent->errstr) {
        $self->errstr($self->parent->errstr);
        return;
    }

    return @buffer;
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
