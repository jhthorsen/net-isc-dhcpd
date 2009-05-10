package Net::DHCPd::Config::OptionSpace;

=head1 NAME

Net::DHCPd::Config::OptionSpace - Option config parameter

=cut

use Moose;
use Net::DHCPd::Config::OptionSpace::NameCodeValue;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 namecodevalues

A list of parsed L<Net::DHCPd::Config::OptionSpace::NameCodeValue> objects.

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::OptionSpace::NameCodeValue
        /);
    },
);

=head2 name

 $string = $self->name;

Name of the option namespace.

=cut

has name => (
    is => 'ro',
    isa => 'Str',
);

=head2 regex

See L<Net::DHCPd::Config::Role>.

=cut

has '+regex' => (
    default => sub { qr{^\s* option \s space \s (.*) ;}x },
);

=head2 endpoint

See L<Net::DHCPd::Config::Role>.

=cut

has '+endpoint' => (
    default => sub { qr" ^ \s* $ "x },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { name => $_[1] }
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
