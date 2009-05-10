package Net::DHCPd::Config::OptionSpace;

=head1 NAME

Net::DHCPd::Config::OptionSpace - Option config parameter

=cut

use Moose;
use Net::DHCPd::Config::OptionSpace::Option;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 namecodevalues

A list of parsed L<Net::DHCPd::Config::OptionSpace::Option> objects.

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::OptionSpace::Option
        /);
    },
);

=head2 name

 $string = $self->name;

Name of the option namespace.

=cut

has name => (
    is => 'rw',
    isa => 'Str',
);

=head2 code

=cut

has code => (
    is => 'rw',
    isa => 'Int',
);

=head2 prefix

Human readable prefix of all child
L<Net::DHCPd::Config::OptionsSpace::Option> objects.

=cut

has prefix => (
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
    default => sub {
        qr{^
            \s* option \s (\S+)
            \s  code \s (\d+) \s =
            \s  encapsulate \s (\S+) ;
        }x;
    },
);

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    return { prefix => $_[1] }
}

=head2 captured_endpoint

=cut

sub captured_endpoint {
    my $self = shift;

    unless($_[2] and $_[2] eq $self->prefix) {
        confess "prefix does not match '$_[2]'";
    }

    $self->name($_[0]);
    $self->code($_[1]);
}

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
