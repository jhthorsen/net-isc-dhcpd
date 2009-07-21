package Net::ISC::DHCPd::Leases;

=head1 NAME 

Net::ISC::DHCPd::Leases - Parse ISC DHCPd leases

=cut

use Moose;
use Net::ISC::DHCPd::Leases::Lease;
use POE::Filter::DHCPd::Lease;

=head1 OBJECT ATTRIBUTES

=head2 leases

 $leases = $self->leases;

=cut

has leases => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 file

=cut

has file => (
    is => 'rw',
    isa => 'Str',
    default => "/var/lib/dhcp3/dhcpd.leases",
);

=head2 filehandle

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

=head1 METHODS

=head2 parse

 $int = $self->parse;

=cut

sub parse {
    my $self   = shift;
    my $fh     = $self->filehandle;
    my $parser = POE::Filter::DHCPd::Lease->new;
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

 $bool = $self->add_lease($lease);

=cut

sub add_lease {
    my $self  = shift;
    my $lease = shift;

    unless(blessed $lease) {
        $lease = Net::ISC::DHCPd::Leases::Lease->new($lease);
    }

    return push @{ $self->leases }, $lease;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
