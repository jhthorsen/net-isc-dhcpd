package Net::DHCPd::Config::Option;

=head1 NAME

Net::DHCPd::Config::Option - Option config parameter

=cut

use Moose;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 regex

See L<Net::DHCPd::Config::Role>.

=cut

has '+regex' => (
    default => sub { qr{^\s* option \s (\S+) \s (.*) ;}x },
);

=head2 name

 $string = $self->name;

Name of the option.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 value

 $string = $self->value;

Value of the option.

=cut

has value => (
    is => 'ro',
    isa => 'Str',
);

=head2 quoted

 $bool = $self->quoted;

This flag tells if the option value should be quoted or not.

=cut

has quoted => (
    is => 'ro',
    isa => 'Bool',
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    my $self   = shift;
    my $name   = shift;
    my $value  = shift;
    my $quoted = 0;

    $quoted = 1 if($value =~ s/^"(.*)"$/$1/g);

    return {
        name   => $name,
        value  => $value,
        quoted => $quoted,
    };
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;