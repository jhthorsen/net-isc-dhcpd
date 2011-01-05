package Net::ISC::DHCPd::Config::Role;

=head1 NAME

Net::ISC::DHCPd::Config::Role - Role with generic config methods and attributes

=head1 DESCRIPTION

This role contains common methods and attributes for each of the config
classes in the L<Net::ISC::DHCPd::Config> namespace.

=cut

use Moose::Role;

requires 'generate';

my %CREATE_CHILD_ATTRIBUTE_ARGUMENTS = (
    is => 'rw',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    default => sub { [] },
);

=head1 ATTRIBUTES

=head2 parent

The parent node in the config tree. This must be an object which does
this role.

=cut

has parent => (
    is => 'rw',
    does => 'Net::ISC::DHCPd::Config::Role',
    weak_ref => 1,
);

=head2 root

The root node in the config tree.

=cut

has root => (
    is => 'ro',
    isa => 'Object',
    lazy => 1,
    weak_ref => 1,
    builder => '_build_root',
);

sub _build_root {
    my $obj = shift;

    while(my $tmp = $obj->parent) {
        blessed($obj = $tmp) eq 'Net::ISC::DHCPd::Config' and last;
    }

    return $obj;
}

=head2 depth

Integer value that counts how far this node is from the root node.

=cut

has depth => (
    is => 'ro',
    isa => 'Int',
    lazy => 1,
    builder => '_build_depth',
);

sub _build_depth {
    my $self = shift;
    my $obj = $self;
    my $i = 0;

    while($obj = $obj->parent) {
        $i++;
        last if($obj == $self->root);
    }

    return $i;
}

=head2 children

Holds a list of possible child objects as objects. This list is used
when L</parse> or L</generate_config_from_children> is called.
The child list has a default value set from L</create_children> in each
of the config modules. This is a static list, which reflects the actual
documentation from C<dhcpd.conf(5)>. Example:

    package Net::ISC::DHCPd::Config::Foo;
    __PACKAGE__->create_children("Net::ISC::DHCPd::Config::Host");

    package main;
    $config = Net::ISC::DHCPd::Config::Foo->new;
    $config->add_host({ ... });
    @host_objects = $config->find_hosts({ ... });
    $config->remove_host({ ... });
    @host_objects = $config->hosts;

The L</create_children> method will autogenerate three methods and an
attribute. The name of the attribute and methods will be the last part
of the config class, with "s" at the end in some cases.

=over 4

=item foos

C<foos> is the name the attribute as well as the accessor. The accessor
will auto-deref the array-ref to a list if called in list context. (yes:
be aware of this!).

=item add_foo

Instead of pushing values directly to the C<foos> list, an C<add_foo>
method is available. It can take either a hash, hash-ref or an object
to add/construct a new child.

=item find_foos

This method will return zero or more objects as a list. It takes
a hash-ref which will be matched against the object attributes of
the children.

=item remove_foo

This method will remove zero or more children from the C<foos> attribute.
The method takes a hash-ref which will be used to match against the
child list. It returns the number of child nodes actually matched and
removed.

=back

=cut

has children => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    builder => '_build_children',
);

sub _build_children { [] }

=head2 regex

Regex used to scan a line of config text, which then spawns an
a new node to the config tree. This is used inside l</parse>.

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
    builder => '_build_regex',
);

=head2 endpoint

Regex to search for before ending the current node block.
Will not be used if the node does not have any possible L</children>.

=cut

has endpoint => (
    is => 'ro',
    isa => 'Maybe[RegexpRef]',
    builder => '_build_endpoint',
);

sub _build_endpoint { qr" ^ \s* } \s* $ "x }

has _filehandle => (
    is => 'ro',
    lazy_build => 1,
);

sub _build__filehandle {
    my $self = shift;
    my $file;

    # get filehandle from parent to prevent seeking file from beginning
    if(my $parent = $self->parent) {
        return $parent->_filehandle;
    }

    $file = $self->file;

    if($file->is_relative and !-e $file) {
        $file = Path::Class::File->new($self->root->file->dir, $file);
    }

    return $file->openr;
}

=head1 METHODS

=head2 parse

Will read a line of the time from the current config
L<file|Net::ISC::DHCPd::Config::Root/file>. For each line, this method
will loop though each object in L</children> and try to match the line
against a given child and create a new node in the object graph if it
match the L</regex>. This method is called recursively for each child
when possible.

=cut

sub parse {
    my $self = shift;
    my $fh = $self->_filehandle;
    my $endpoint = $self->endpoint;
    my $n = 0;
    my $pos;

    LINE:
    while(1) {
        $pos = $fh->getpos or die $!;
        defined(my $line = readline $fh) or last LINE;
        my $res;
        $n++;

        if($self->can('slurp')) {
            my $action = $self->slurp($line); # next or last
            if($action eq 'next') {
                next LINE;
            }
            elsif($action eq 'last') {
                last LINE;
            }
            elsif($action eq 'backtrack') {
                $fh->setpos($pos);
                $n--;
                last LINE;
            }
        }
        elsif($line =~ $endpoint) {
            $self->captured_endpoint($1, $2, $3, $4); # urk...
            next LINE if($self->root == $self);
            last LINE;
        }

        CHILD:
        for my $child ($self->children) {
            my @c = $line =~ $child->regex or next CHILD;
            my $add = 'add_' .lc +(ref($child) =~ /::(\w+)$/)[0];
            my $new = $self->$add( $child->captured_to_args(@c) );

            $n += $new->parse('recursive') if(@_ = $new->children);

            last CHILD;
        }
    }

    return $n ? $n : '0e0';
}

=head2 captured_to_args

 $hash_ref = $self->captured_to_args(@list);

Called when a L</regex> matches, with a list of captured strings.
This method then returns a hash-ref passed on to the constructor when
a new node in the object graph is constructed.

=cut

sub captured_to_args {
    return {};
}

=head2 captured_endpoint
 
    $self->captured_endpoint(@list)

Called when a L</endpoint> matches, with a list of captured strings.

=cut

sub captured_endpoint {
    return;
}

=head2 create_children

This method takes a list of classes, and creates builder method for
the L</children> attribute, an attribute and helper methods. See
L</children> for more details.

=cut

sub create_children {
    my $self = shift;
    my $meta = $self->meta;
    my @children = @_;
    my $condition_class = $meta->name .'::Condition';
    my $condition_meta;

    $meta->add_method(_build_children => sub { \@children });

    $condition_meta = $meta->create($condition_class => (
                          superclasses => [ 'Moose::Object' ],
                          roles => [ 'Net::ISC::DHCPd::Config::ConditionRole' ],
                          methods => {
                              _build_children => sub { \@children },
                          },
                      ));

    push @children, $condition_class;

    for my $obj (@children) {
        my $class = $obj; # copy classname
        my $name = lc +($class =~ /::(\w+)$/)[0];
        my $attr = $name .'s';

        Class::MOP::load_class($class);

        unless($meta->get_attribute($attr)) {
            $meta->add_method("add_${name}" => sub { shift->_add_child(@_, $attr, $class) });
            $condition_meta->add_method("add_${name}" => sub { shift->_add_child(@_, $attr, $class) });

            $meta->add_method("find_${name}s" => sub { shift->_find_children(@_, $attr) });
            $condition_meta->add_method("find_${name}s" => sub { shift->_find_children(@_, $attr) });

            $meta->add_method("remove_${name}s" => sub { shift->_remove_children(@_, $attr) });
            $condition_meta->add_method("remove_${name}s" => sub { shift->_remove_children(@_, $attr) });

            $condition_meta->add_attribute($attr => (
                %CREATE_CHILD_ATTRIBUTE_ARGUMENTS,
                trigger => sub {
                    for my $e (@{ $_[1] }) {
                        next if(blessed $e);
                        next if(ref $e ne 'HASH');
                        $e = $class->new(parent => $_[0], %$e);
                    }
                },
            ));

            $meta->add_attribute($attr => (
                %CREATE_CHILD_ATTRIBUTE_ARGUMENTS,
                trigger => sub {
                    for my $e (@{ $_[1] }) {
                        next if(blessed $e);
                        next if(ref $e ne 'HASH');
                        $e = $class->new(parent => $_[0], %$e);
                    }
                },
            ));
        }

        # replace class bareword with object in @children
        $obj = $class->new;
    }

    return \@children;
}

sub _add_child {
    my $self = shift;
    my $class = pop;
    my $accessor = pop;
    my $args = @_ == 1 ? $_[0] : {@_};

    eval { push @{ $self->$accessor }, $class->new(%$args, parent => $self) };
    print join "\n", map { $_->name } $class->meta->get_all_attributes if $@;
    die $@ if($@);

    return ${ $self->$accessor }[-1];
}

sub _find_children {
    my $accessor = pop;
    my $self = shift;
    my $query = shift or return;
    my @children;

    CHILD:
    for my $child ($self->$accessor) {
        for my $key (keys %$query) {
            next CHILD unless($child->$key eq $query->{$key});
        }
        push @children, $child;
    }

    return @children;
}

sub _remove_children {
    my $accessor = pop;
    my $self = shift;
    my $query = shift or return;
    my $children = $self->$accessor;
    my @removed;

    CHILD:
    for my $i (0..$#$children) {
        for my $key (keys %$query) {
            next CHILD unless($children->[$i]->$key eq $query->{$key});
        }
        push @removed, splice @$children, $i, 1;
    }

    return @removed;
}

=head2 generate_config_from_children

Loops all child nodes in reverse order and calls L</generate> on each
of them. Each L</generate> method must return a list of strings which
will be indented correctly and concatenated with newline inside this
method, before returned as one string.

=cut

sub generate_config_from_children {
    my $self = shift;
    my $indent = '';
    my @text;

    if($self->parent and !$self->can('generate_with_include')) {
        $indent = ' ' x 4;
    }

    for(reverse $self->children) {
        my($attr) = lc +((blessed $_) =~ /::(\w+)$/ )[0] .'s';

        for my $node ($self->$attr) {
            push @text, map { "$indent$_" } $node->generate;
        }
    }

    return join "\n", @text;
}

=head2 generate

A C<generate()> must be defined in the consuming class. This method
must return a list of lines (zero or more), which will be indented
and concatenated inside L</generate_config_from_children>.

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
