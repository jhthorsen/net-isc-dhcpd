package Net::ISC::DHCPd::Leases;

=head1 NAME

Net::ISC::DHCPd::Leases - Parse ISC DHCPd leases

=head1 SYNOPSIS

    my $leases = Net::ISC::DHCPd::Leases->new(
                     file => '/var/lib/dhcp3/dhcpd.leases',
                 );

    # parse the leases file
    $leases->parse;

    for my $lease ($leases->leases) {
        say "lease has ended" if($lease->ends < time);
    }

    if(my $n = $leases->find_leases({ ends => time }) {
        say "$n lease(s) has expired now";
    }

=head1 DESCRIPTION

An object constructed from this class represents a leases file for
the dhcpd server. It is read-only, so changes to the leases file
must be done through a running server, using L<Net::ISC::DHCPd::OMAPI>.

The object has one important attribute, which is L</leases>. This
attribute holds a list of L<Net::ISC::DHCPd::Leases::Lease> objects
constructed from all the leases found in the leases file.

To parse the leases file, this module use L<POE::Filter::DHCPd::Lease>,
but this can be customized by setting C<_parser> in the constructor.
Even though it is possible, it is recommended to add features/
bugfixes to L<POE::Filter::DHCPd::Lease|https://rt.cpan.org/Public/Dist/Display.html?Name=POE-Filter-DHCPd-Lease>
instead.

=cut

use Moose;
use Net::ISC::DHCPd::Leases::Lease;
use POE::Filter::DHCPd::Lease 0.0701;
use MooseX::Types::Path::Class 0.05 qw(File);

=head1 ATTRIBUTES

=head2 leases

Holds a list of all the leases found after reading the leases file.

=cut

has leases => (
    is => 'ro',
    isa => 'ArrayRef',
    auto_deref => 1,
    default => sub { [] },
);

=head2 file

This attribute holds a L<Path::Class::File> object to the leases file.
It is read-write and the default value is "/var/lib/dhcp3/dhcpd.leases".

=cut

has file => (
    is => 'rw',
    isa => File,
    coerce => 1,
    default => sub {
        Path::Class::File->new('', 'var', 'lib', 'dhcp3', 'dhcpd.leases');
    },
);

has fh => (
    is => 'rw',
    isa => 'FileHandle',
    required => 0,
);

has _filehandle => (
    is => 'ro',
    lazy_build => 1,
);

sub _build__filehandle {
    my $self = shift;
    if ($self->fh) {
        return $self->fh;
    }

    $self->file->openr;
}

__PACKAGE__->meta->add_method(filehandle => sub {
    Carp::cluck('->filehandle is replaced with private attribute _filehandle');
    shift->_filehandle;
});

has _parser => (
    is => 'ro',
    isa => 'Object',
    default => sub { POE::Filter::DHCPd::Lease->new },
);

=head1 METHODS

=head2 parse

Read lines from L</file>, and parses every lease it can find.
Returns the number of leases found. Will add each found lease to
L</leases>.

=cut

sub parse {
    my $self = shift;
    my $fh = $self->_filehandle;
    my $parser = $self->_parser;
    my $n = 0;

    while(my $line = readline $fh) {
        $n++;

        $parser->get_one_start([$line]);
        if ($line =~ /^\s*}/) {
            my $leases = $parser->get_one;
            #print scalar @$leases;
            if (@$leases) {
                $self->add_lease($leases->[0]);
            }
        }
    }

    return $n;
}

=head2 find_leases

This method will return zero or more L<Net::ISC::DHCPd::Leases::Lease>
objects as a list. It takes a hash-ref which will be matched against
the attributes of the child leases.

=cut

sub find_leases {
    my $self = shift;
    my $query = shift or return;
    my @leases;

    LEASE:
    for my $lease ($self->leases) {
        for my $key (keys %$query) {
            next LEASE unless($lease->$key eq $query->{$key});
        }
        push @leases, $lease;
    }

    return @leases;
}

=head2 add_lease

This method does not make much sense, and will probably get removed.
See L</DESCRIPTION> for more details.

=cut

sub add_lease {
    my $self  = shift;

    if(blessed $_[0]) {
        return push @{$self->leases}, $_[0];
    }

    my %lease = %{ $_[0] }; # shallow copy
    my %map = (
        ip      => 'ip_address',
        binding => 'state',
        hostname => 'client_hostname',
        hw_ethernet => 'hardware_address',
    );

    for my $key (keys %map) {
        if(defined $lease{$key}) {
            $lease{ $map{$key} } = delete $lease{$key};
        }
    }

    return push @{$self->leases}, Net::ISC::DHCPd::Leases::Lease->new(\%lease);
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
