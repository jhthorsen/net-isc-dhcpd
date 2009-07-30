package Net::ISC::DHCPd::Leases;

=head1 NAME 

Net::ISC::DHCPd::Leases - Parse ISC DHCPd leases

=cut

use Moose;
use Net::ISC::DHCPd::Leases::Lease;
use POE::Filter::DHCPd::Lease;

=head1 OBJECT ATTRIBUTES

=head2 leases

 $array_ref = $self->leases;

Holds all known lease objects.

=cut

has leases => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 file

 $str = $self->file;

Holds the path to the dhcpd.leases file.

Default: "/var/lib/dhcp3/dhcpd.leases"

=cut

has file => (
    is => 'rw',
    isa => 'Str',
    default => "/var/lib/dhcp3/dhcpd.leases",
);

=head2 filehandle

 $glob = $self->filehandle;
 $bool = $self->has_filehandle;
 $self->clear_filehandle;

Holds the filehande to l<file>.

=cut

has filehandle => (
    is => 'ro',
    isa => 'GlobRef',
    lazy_build => 1,
);

sub _build_filehandle {
    my $self = shift;
    my $file = $self->file or confess 'file attribute needs to be set';
    open(my $FH, "<", $file) or confess "cannot open $file: $!";
    return $FH;
}

has _parser => (
    is => 'ro',
    isa => 'Object',
    default => sub { POE::Filter::DHCPd::Lease->new },
);

=head1 METHODS

=head2 parse

 $int = $self->parse;

Read lines from L<filehandle>, and parses every lease it can find.
Returns the number of leases found. Will add each found lease to L<leases>.

=cut

sub parse {
    my $self   = shift;
    my $fh     = $self->filehandle;
    my $parser = $self->_parser;
    my $n      = 0;

    LINE:
    while(++$n) {
        my $line = readline $fh;

        if(not defined $line) {
            $n--;
            last LINE;
        }

        $parser->get_one_start([$line]);

        if($line =~ $POE::Filter::DHCPd::Lease::END) {
            $self->add_lease( @{ $parser->get_one } );
        }
    }

    return $n;
}

=head2 add_lease

 $bool = $self->add_lease($lease_obj);

All another L<Net::ISC::DHCPd::Leases::Lease> object to the
L<leases> attribute>.

=cut

sub add_lease {
    my $self  = shift;

    if(blessed $_[0]) {
        return push @{$self->leases}, $_[0];
    }

    my %lease = %{ $_[0] }; # shallow copy
    my %map = (
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

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
