package Net::ISC::DHCPd::Config::Block;

=head1 NAME

Net::ISC::DHCPd::Config::Block - Unknown config blocks

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

An instance from this class, comes from / will produce:

    $type $name {
        $body_attribute_value
    }

    $type "$string" {
        $body_attribute_value
    }

IMPORTANT! "Blocks" may be redefined to a "real" instance later on.
This is simply here as a "catch-all" feature, in case something
could not be parsed.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 ATTRIBUTES

=head2 type

See L</SYNOPSIS>.

=head2 name

See L</SYNOPSIS>.

=cut

has [qw/ type name /] => (
    is => 'ro',
    isa => 'Str',
);

=head2 quoted

This flag tells if the name should be quoted or not.

=cut

has quoted => (
    is => 'ro',
    isa => 'Bool',
);

=head2 body

The body of the block, without trailing newline at end.
This text is not parsed, so the containing text can be anything.

=cut

has body => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

# need around modifier, since
# trigger => sub { shift->_chomp_body },
# results in recursion
around body => sub {
    my $next = shift;
    my $self = shift;

    if(@_) {
        my $text = shift;
        chomp $text;
        return $self->$next($text);
    }

    return $self->$next;
};

sub _build_children { [undef] }
sub _build_regex { qr/^\s* ([\w-]+) \s+ (\S*) \s* { /x }

has _depth => (
    is => 'ro',
    isa => 'Int',
    traits => ['Counter'],
    default => 1,
    handles => {
        _inc_depth => 'inc',
        _dec_depth => 'dec',
    },
);

=head1 METHODS

=head2 BUILD

Will make sure L</body> does not contain trailing newlines.

=cut

sub BUILD {
    $_[0]->body($_[0]->body);
}

=head2 slurp

This method is used by L<Net::ISC::DHCPd::Config::Role/parse>, and will
slurp the content of the function, instead of trying to parse the
statements.

=cut

sub slurp {
    my($self, $line) = @_;

    $self->_inc_depth if($line =~ /{/);
    $self->_dec_depth if($line =~ /}/);

    if($self->_depth) {
        my $body = $self->body;
        $self->body(length $body ? "$body\n$line" : $line);
        return 'next';
    }
    else {
        $self->body($self->body);
        return 'last';
    }
}

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    my($self, $type, $name) = @_;
    my $quoted = $name =~ s/^"(.*)"$/$1/ ? 1 : 0;

    return { type => $type, name => $name, quoted => $quoted }
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    return(
        $self->quoted ?
              sprintf('%s "%s" {', $self->type, $self->name)
            : sprintf('%s %s {', $self->type, $self->name),
        $self->body,
        '}',
    );
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
