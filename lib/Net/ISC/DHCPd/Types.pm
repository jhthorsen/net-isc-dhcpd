package Net::ISC::DHCPd::Types;

=head1 NAME

Net::ISC::DHCPd::Types - Moose type constraint declaration

=head1 SYNOPSIS

 use Net::ISC::DHCPd::Types @types;
 has foo => ( isa => SomeType, ... );
 1;

=cut

use Moose;
use MooseX::Types::Moose ':all';
use MooseX::Types -declare => [qw/
    HexInt Ip Mac State Time
    ConfigObject LeasesObject OMAPIObject ProcessObject
/];

my @states = qw/na free active expired released
                abandoned reset backup reserved bootp/;

=head1 MOOSE TYPES

=head2 HexInt

=head2 Ip

=head2 Mac

=head2 State

=head2 Time

=cut

subtype State, as Str, where { my $s = $_; return grep { $s eq $_ } @states };
subtype HexInt, as Int;
subtype Ip, as Str, where { not /:/ };
subtype Mac, as Str, where { /[\w:]+/ };
subtype Time, as Int;

coerce State, (
    from Str, via { /(\d+)$/ ? $states[$1] : undef }
);

coerce HexInt, (
    from Str, via { s/://g; hex $_ },
);

coerce Time, (
    from Str, via { s/://g; hex $_ },
);

coerce Ip, (
    from Str, via { join ".", map { hex $_ } split /:/ },
);

=head2 ConfigObject

=head2 LeasesObject

=head2 OMAPIObject

=head2 ProcessObject

=cut

subtype ConfigObject, as Object;
subtype LeasesObject, as Object;
subtype OMAPIObject, as Object;
subtype ProcessObject, as Object;

coerce ConfigObject, from HashRef, via {
    eval "require Net::ISC::DHCPd::Config" or confess $@;
    Net::ISC::DHCPd::Config->new($_);
};
coerce LeasesObject, from HashRef, via {
    eval "require Net::ISC::DHCPd::Leases" or confess $@;
    Net::ISC::DHCPd::Leases->new($_);
};
coerce OMAPIObject, from HashRef, via {
    eval "require Net::ISC::DHCPd::OMAPI" or confess $@;
    Net::ISC::DHCPd::OMAPI->new($_);
};
coerce ProcessObject, from HashRef, via {
    eval "require Net::ISC::DHCPd::Process" or confess $@;
    Net::ISC::DHCPd::Process->new($_);
};

=head1 AUTHOR

See L<Net::ISC::DHCPd>

=cut

1;
