package Net::ISC::DHCPd::OMAPI::Lease;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Lease - OMAPI lease class

=head1 SEE ALSO

L<Net::ISC::DHCPd::OMAPI::Actions>.
L<Net::ISC::DHCPd::OMAPI::Meta::Attribute>.

=head1 SYNOPSIS

 use Net::ISC::DHCPd::OMAPI;

 $omapi = Net::ISC::DHCPd::OMAPI->new(...);
 $omapi->connect
 $lease = $omapi->new_object("lease", { $attr => $value });
 $lease->$attr($value); # same as in constructor
 $lease->read; # retrieve server information
 $lease->set($attr => $value); # alter an update attr
 $lease->write; # write to server

=cut

use Moose;
use MooseX::Types -declare => [qw/HexInt Ip Mac State Time/];
use MooseX::Types::Moose ':all';

with 'Net::ISC::DHCPd::OMAPI::Actions';

my @states = qw/na free active expired released
                abandoned reset backup reserved bootp/;

subtype State, as Str, where { my $s = $_; return grep { $s eq $_ } @states };
subtype HexInt, as Int;
subtype Ip, as Str, where { not /:/ };
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
    from Str, via { join ".", map { hex $_ } split /:/ },
);

=head1 ATTRIBUTES

=head2 atsfp

 $int = $self->atsfp;
 $self->atsfp($int);

The actual tsfp value sent from the peer. This value is forgotten when a
lease binding state change is made, to facillitate retransmission logic.

Actions: examine.

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

Actions: none.

=cut

has billing_class => (
    is => 'rw',
    isa => Any,
);

=head2 client_hostname

 $self->client_hostname($str);
 $str = $self->client_hostname;

The value the client sent in the host-name option.

Actions: examine, update.

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

Actions: examine.

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

Actions: examine, lookup, update.

=cut

has dhcp_client_identifier => (
    is => 'rw',
    isa => Str,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine lookup update/],
    predicate => 'has_dhcp_client_identifier',
);

=head2 ends

 $self->ends($int);
 $int = $self->ends;

The time when the lease's current state ends, as understood by the client.

Actions: examine.

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

Actions: none.

=cut

has flags => (
    is => 'rw',
    isa => 'Str',
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
);

=head2 hardware_address

 $self->hardware_address($str);
 $str = $self->hardware_address;

The hardware address (chaddr) field sent by the client when it acquired
its lease.

Actions: examine, update.

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

Actions: examine, update.

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

Actions: examine.

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
 $std_ip_str = $self->ip_address;

The IP address of the lease.

Actions: examine, lookup.

=cut

has ip_address => (
    is => 'rw',
    isa => Ip,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine lookup/],
    predicate => 'has_ip_address',
);

=head2 pool

 ?? = $self->pool;
 $self->pool(??);

The pool object associted with this lease (The pool object is not
currently supported).

Actions: examine.

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

Actions: examine.

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

Valid states: free, active, expired, released, abandoned, reset, backup,
reserved, bootp.

Actions: examine, lookup.

=cut

has state => (
    is => 'rw',
    isa => State,
    coerce => 1,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine lookup/],
    predicate => 'has_state',
);

=head2 subnet

 ?? = $self->subnet;
 $self->subnet(??);

The subnet object associated with this lease. (The subnet object is not
currently supported).

Actions: examine.

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

Actions: examine.

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

Actions: examine.

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

Actions: examine, update.

=cut

has hardware_address => (
    is => 'rw',
    isa => Mac,
    traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
    actions => [qw/examine update/],
);

=head1 ACKNOWLEDGEMENTS

Most of the documentation is taken from C<dhcpd(8)>.

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
