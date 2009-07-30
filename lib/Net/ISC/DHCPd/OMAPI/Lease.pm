package Net::ISC::DHCPd::OMAPI::Lease;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Lease

=head1 SEE ALSO

L<Net::ISC::DHCPd::OMAPI::Group>.

=head1 SYNOPSIS

 use Net::ISC::DHCPd::OMAPI;

 $omapi = Net::ISC::DHCPd::OMAPI->new(...);
 $omapi->connect
 $lease = $omapi->new_object("lease"); # object of this class
 $lease->set($attr => $value);
 # ...

=cut

use Moose;
use MooseX::Types -declare => [qw/HexInt Ip Mac State Time/];
use MooseX::Types::Moose ':all';
use NetAddr::IP;

with 'Net::ISC::DHCPd::OMAPI::Role';

my @states = qw/na free active expired released
                abandoned reset backup reserved bootp/;

subtype State, as Str, where { my $s = $_; return grep { $s eq $_ } @states };
subtype HexInt, as Int;
subtype Ip, as Object;
subtype Mac, as Str, where { /[\w:]+/ };
subtype Time, as Int;

coerce State, (
    from Str, via { /(\d+)$/ ? $states[$1] : undef }
);

coerce HexInt, (
    from Str, via { s/://g; return hex },
);

coerce Time, (
    from Str, via { s/://g; return hex },
);

coerce Ip, (
    from Str, via {
        NetAddr::IP->new( /:/ ? join(".", map { hex $_ } split /:/) : $_ );
    },
);

=head1 ATTRIBUTES

=head2 atsfp

 $int = $self->atsfp;
 $self->atsfp($int);

The actual tsfp value sent from the peer. This value is forgotten when a
lease binding state change is made, to facillitate retransmission logic.

=cut

has atsfp => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 billing_class

 ?? = $self->billing_class;
 $self->billing_class(??);

The handle to the class to which this lease is currently billed,
if any (The class object is not currently supported).

=cut

has billing_class => (
    is => 'rw',
    isa => Any,
);

=head2 client_hostname

 $self->client_hostname($str);
 $str = $self->client_hostname;

The value the client sent in the host-name option.

=cut

has client_hostname => (
    is => 'rw',
    isa => Str,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine update/],
);

=head2 cltt

 $int = $self->cltt;
 $self->cltt($int);

The time of the last transaction with the client on this lease.

=cut

has cltt => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 dhcp_client_identifier

 $self->dhcp_client_identifier(??);
 ?? = $self->dhcp_client_identifier;

The client identifier that the client used when it acquired the lease.
Not all clients send client identifiers, so this may be empty.

=cut

has dhcp_client_identifier => (
    is => 'rw',
    isa => Str,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine lookup update/],
);

=head2 ends

 $self->ends($int);
 $int = $self->ends;

The time when the lease's current state ends, as understood by the client.

=cut

has ends => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 flags

 ?? = $self->flags;
 $self->flags(??);

=cut

has flags => (
    is => 'rw',
    isa => 'Str',
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 hardware_address

 $self->hardware_address($str);
 $str = $self->hardware_address;

The hardware address (chaddr) field sent by the client when it acquired
its lease.

=cut

has hardware_address => (
    is => 'rw',
    isa => Mac,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine update/],
);

=head2 hardware_type

 $self->hardware_type($str);
 $str = $self->hardware_type;

The type of the network interface that the client reported when it
acquired its lease.

=cut

has hardware_type => (
    is => 'rw',
    isa => HexInt,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine update/],
);

=head2 host

 $self->host(??);
 ?? = $self->host;

The host declaration associated with this lease, if any.

=cut

has host => (
    is => 'rw',
    isa => Any,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 ip_address

 $self->ip_address($ip_addr_obj);
 $self->ip_address("127.0.0.1"); # standard ip
 $self->ip_address("22:33:aa:bb"); # hex
 $ip_addd_obj = $self->ip_address;

The IP address of the lease.

=cut

has ip_address => (
    is => 'rw',
    isa => Ip,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/lookup examine/],
);

=head2 pool

 ?? = $self->pool;
 $self->pool(??);

The pool object associted with this lease (The pool object is not
currently supported).

=cut

has pool => (
    is => 'rw',
    isa => Any,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 starts

 $self->starts($int);
 $int = $self->starts;

The time when the lease's current state ends, as understood by the server.

=cut

has starts => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 state

 $self->state($str);
 $str = $self->state;

Valid states: free active expired released abandoned reset backup reserved
bootp.

=cut

has state => (
    is => 'rw',
    isa => State,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine lookup/],
);

=head2 subnet

 ?? = $self->subnet;
 $self->subnet(??);

The subnet object associated with this lease. (The subnet object is not
currently supported).

=cut

has subnet => (
    is => 'rw',
    isa => Any,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 tsfp

 $self->tsfp($int);
 $int = $self->tsfp;

The adjusted time when the lease's current state ends, as understood by
the failover peer (if there is no failover peer, this value is undefined).
Generally this value is only adjusted for expired, released, or reset
leases while the server is operating in partner-down state, and otherwise
is simply the value supplied by the peer.

=cut

has tsfp => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 tstp

 $self->tstp($int);
 $int = $self->tstp;

The time when the lease's current state ends, as understood by the server.

=cut

has tstp => (
    is => 'rw',
    isa => Time,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine/],
);

=head2 hardware_address

 $self->hardware_address($str);
 $str = $self->hardware_address;

The hardware address (chaddr) field sent by the client when it acquired
its lease.

=cut

has hardware_address => (
    is => 'rw',
    isa => Mac,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine update/],
);

=head1 METHODS

=head2 primary

 $str = $self->primary;

Returns the primary key for this object: "ip_address".

=cut

sub primary { 'ip_address' }

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
