package Net::ISC::DHCPd::Config::Function;

=head1 NAME

Net::ISC::DHCPd::Config::Function - Function config parameters

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 name

 $string = $self->name

Name of the the function.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 body

 $text = $self->body
 $int = $self->body_length;
 $bool = $self->replace_body($pattern, $replacement);
 $self->append_body($text);
 $self->prepend_body($text);

The body text of the function, without trailing newline at end.

=cut

has body => (
    is => 'rw',
    isa => 'Str',
    traits => ['String'],
    default => '',
    handles => {
        append_body => 'append',
        prepend_body => 'prepend',
        body_length => 'length',
        replace_body => 'replace',
    },
);

# need around modifier, since
# trigger => sub { shift->_chomp_body },
# results in recursion
around body => sub {
    my $next = shift;
    my $self = shift;

    if(my @text = @_) {
        chomp @text;
        return $self->$next(@text);
    }

    return $self->$next;
};

sub _build_children { [undef] }
sub _build_regex { qr{^\s* on \s (\w+)}x }

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

This method will slurp the content of the function, instead of
trying to parse the statements.

=cut

sub slurp {
    my $self = shift;
    my $line = shift;

    $self->_inc_depth if($line =~ /{/);
    $self->_dec_depth if($line =~ /}/);

    if($self->_depth) {
        $self->append_body($line);
        return 'next';
    }
    else {
        $self->body($self->body);
        return 'last';
    }
}

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role::captured_to_args()>.

=cut

sub captured_to_args {
    return { name => $_[1] }
}

=head2 generate

See L<Net::ISC::DHCPd::Config::Role::generate()>.

=cut

sub generate {
    return sprintf 'on %s {', $_[0]->name), $_[0]->body, '}';
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
