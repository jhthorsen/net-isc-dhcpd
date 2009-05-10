package Net::DHCPd::Config::Role;

=head1 NAME

Net::DHCPd::Config::Role - Generic config methods and attributes

=cut

use Moose::Role;

=head1 OBJECT ATTRIBUTES

=head2 parent

=cut

has parent => (
    is => 'ro',
    isa => 'Net::DHCPd::Config::Role',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
);

=head2 root

=cut

has root => (
    is => 'ro',
    isa => 'Net::DHCPd::Config',
    weak_ref => 1,
    lazy => 1,
    default => sub { shift }, # used when constructing Net::DHCPd::Config
);

=head2 children

=cut

has children => (
    is => 'rw',
    isa => 'ArrayRef',
    auto_deref => 1,
    default => sub { [] },
);

has _children => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy => 1,
    auto_deref => 1,
    default => sub { [] },
);

=head2 regex

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
);

=head2 endpoint

=cut

has endpoint => (
    is => 'ro',
    isa => 'Maybe[RegexpRef]',
    default => sub { qr" ^ \s* } \s* $ "x },
);

=head1 METHODS

=head2 parse

 $int = $self->parse;

=cut

sub parse {
    my $self     = shift;
    my $fh       = $self->root->filehandle;
    my $endpoint = $self->endpoint;
    my $n        = 0;

    LINE:
    while(++$n) {
        my $line = readline $fh;
        my $res;

        if(not defined $line) {
            $n--;
            last LINE;
        }
        if($line =~ $endpoint) {
            last LINE;
        }

        CHILD:
        for my $child ($self->_children) {
            my @captured = $line =~ $child->regex or next CHILD;
            my $new      = $self->append($child, @captured);

            $n += $new->parse if(@_ = $new->_children);

            last CHILD;
        }
    }

    return $n ? $n : "0e0";
}

=head2 append

 $new_child = $self->append($child, @captured)

Called from L<parse()>, with the child object and the captured elements
from the L<regex()>.

This role provides a default method that does nothing. Should be overriden
in each class.

=cut

sub append {
    my $self  = shift;
    my $child = shift;
    my $args  = $child->captured_to_args(@_);
    my $type  = lc +(ref($child) =~ /::(\w+)$/)[0] ."s";
    my $new   = $child->meta->clone_object($child, %$args);

    push @{ $self->$type }, $new;

    return $new;
}

=head2 captured_to_args

 $hash_ref = $self->captured_to_args(...);

=cut

sub captured_to_args {
    return {};
}

=head2 create_children

 $objs = $self->create_children(@classnames)

=cut

sub create_children {
    my $self = shift;
    my $meta = $self->meta;
    my @list = @_;

    for my $obj (@list) {
        my $name = lc +($obj =~ /::(\w+)$/)[0] ."s";

        unless($meta->get_attribute($name)) {
            $meta->add_attribute($name => (
                is => "rw",
                isa => "ArrayRef[$obj]",
                lazy => 1,
                auto_deref => 1,
                default => sub { [] },
            ));
        }

        $obj = $obj->new(root => $self->root, parent => $self);
    }

    return \@list;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
