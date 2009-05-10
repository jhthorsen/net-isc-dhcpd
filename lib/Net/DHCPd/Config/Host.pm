package Net::DHCPd::Config::Host;

=head1 NAME

Net::DHCPd::Config::Host - Host config parameter

=head1 SYNOPSIS

 $host = Net::DHCPd::Config::Host->new(hostname => "foo.com");

 print $host->hostname;

 for my $option ($host->options) {
    print "> ", $option->name, ":", $option->value, "\n";
 }

 print "> filename: ", $host->filenames->[0]->file;

=cut

use Moose;
use Net::DHCPd::Config::Option;
use Net::DHCPd::Config::Filename;

with 'Net::DHCPd::Config::Role';

=head1 OBJECT ATTRIBUTES

=head2 hostname

 $string = $self->hostname;

=cut

has hostname => (
    is => 'ro',
    isa => 'Str',
);

=head2 options

A list of parsed L<Net::DHCPd::Config::Option> objects.

=head2 filenames

A list of parsed L<Net::DHCPd::Config::Filename> objects.

Should only be one item in this list.

=cut

has '+_children' => (
    default => sub {
        shift->create_children(qw/
            Net::DHCPd::Config::Option
            Net::DHCPd::Config::Filename
        /);
    },
);

=head2 regex

See L<Net::DHCPd::Config::Role>

=cut

has '+regex' => (
    default => sub { qr{^ \s* host (\S+)}x },
);

=head1 AUTHOR

See L<Net::DHCPd>.

=cut

1;
