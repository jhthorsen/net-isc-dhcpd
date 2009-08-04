package Net::ISC::DHCPd::OMAPI::Actions;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Actions - Common actions on OMAPI objects

=head1 DESCRIPTION

Changing object attributes will not alter the attributes on server. To do
so, either use L<set()> directly or use L<write()> after altering attributes.

=cut

use Moose::Role;

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

=head2 extra_attributes

 $hash_ref = $self->extra_attributes;

Contains all attributes, which is not defined for the OMAPI object.

=cut

has extra_attributes => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

=head1 METHODS

=head2 read 

 $int = $self->read;

Open an object. Returns the number of attributes read. 0 = not in server.

It looks up an object on server, by all the attributes that has action
C<lookup>. Will update all attributes in the local object, and setting
all unknown objects in L<extra_attributes>.

=cut

sub read {
    my $self = shift;
    my(@cmd, @out, $n);

    @out = $self->_open;

    %{ $self->extra_attributes } = (); # clear all extra attributes

    while($out[-1] =~ /(\S+)\s=\s(\S+)/g) {
        my($attr, $value) = ($1, $2);
        $attr =~ s/-/_/g;
        $n++;

        if($self->meta->has_attribute($attr)) {
            $self->$attr($value);
        }
        else {
            $self->extra_attributes->{$attr} = $value;
        }
    }

    return $n;
}

around read => \&_around;

=head2 write

 $bool = $self->write;
 $bool = $self->write(@attributes);

Will set attributes on server object.

C<@attributes> is by default every attribute on create, or every
attribute with action "modify" on update.

=cut

sub write {
    my $self = shift;
    my @attr = @_;
    my $new  = 1;
    my(@cmd, @out);

    # check for existence
    @out = $self->_open;

    if($out[-1] =~ /(\S+)\s=\s(\S+)/g) {
        $new = 0;
    }

    if(@attr == 0) {
        my $attr_role = "Net::ISC::DHCPd::OMAPI::Meta::Attribute";
        for my $attr ($self->meta->get_all_attributes) {
            next if(!$attr->does($attr_role));
            next if(!$attr->has_action('modify') and !$new);
            next if($attr->has_action('modify') and !$new);
            push @attr, $attr->name;
        }
    }

    for my $name (@attr) {
        my $key = $name;
        $key =~ s/_/-/g;
        push @cmd, 'set %s = %s', $key, $self->$name;
    }

    # set attributes
    @out = $self->_cmd(@cmd);

    # need to test @out
    # ...

    # update or create
    $self->_cmd( $new ? "create" : "update" ) or return;

    return $new ? +1 : -1;
}

around write => \&_around;

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

# @out = $self->_open;
sub _open {
    my $self = shift;
    my @cmd;

    for my $name ($self->meta->get_attribute_list) {
        my $attr = $self->meta->get_attribute($name);
        my $key = $name;

        next unless($attr->does("Net::ISC::DHCPd::OMAPI::Meta::Attribute"));
        next unless($attr->has_action("lookup"));
        next unless($self->${ \"has_$name" });

        $key =~ s/_/-/g;

        push @cmd, sprintf 'set %s = %s', $key, $self->$name;
    }

    return $self->_cmd(@cmd, "open");
}

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
