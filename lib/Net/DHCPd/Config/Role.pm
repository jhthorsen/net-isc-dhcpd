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
);

=head2 root

=cut

has root => (
    is => 'ro',
    isa => 'Net::DHCPd::Config::Role',
    weak_ref => 1,
);

=head2 children

=cut

has children => (
    is => 'ro',
    isa => 'ArrayRef',
    auto_deref => 1,
);

=head2 regex

=cut

has regex => (
    is => 'ro',
    isa => 'RegexpRef',
    default => qr{},
);

=head2 endpoint

=cut

has endpoint => (
    is => 'ro',
    isa => 'RegexpRef',
    default => qr[ ^ \s* } \s* $ ],
);

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    
    for my $child ($self->children) {
        $child->parent($self);
        $child->root($self->root);
    }

    return 1;
}

=head2 parse

=cut

sub parse {
    my $self     = shift;
    my $fh       = $self->root->filehandle;
    my $endpoint = $self->endpoint;
    my $n;

    LINE:
    while(++$n) {
        my $line = readline $fh;
        my $res;

        if(not defined $line) {
            last LINE;
        }
        if($line =~ $endpoint) {
            last LINE;
        }

        CHILD:
        for my $child ($self->children) {
            my @captured = $line =~ $child->regex or next CHILD;
            $child->save(@captured);
            $child->parse if($child->children);
            last CHILD;
        }
    }

    return $n ? $n : "0e0";
}

=head2 save

=cut

sub save {
    my $self = shift;
    my @data = @_;

    return 1;
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
