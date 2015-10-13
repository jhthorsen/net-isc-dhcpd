package Net::ISC::DHCPd::Types;

=head1 NAME

Net::ISC::DHCPd::Types - Moo type constraint declaration

=head1 SYNOPSIS

 use Net::ISC::DHCPd::Types @types;
 has foo => ( isa => SomeType, ... );

=cut

our @types = qw(
    State
    HexInt
    FailoverState
    Timei
    Ip
    Mac
    ConfigObject
    LeasesObject
    OMAPIObject
    Statements
);

use Sub::Quote qw( quote_sub );
use Type::Library -base, -declare => @types;
use Types::Standard -types;
use Type::Utils -all;
use namespace::autoclean 0.16;

our @failover_states = (
    'na',                     'partner down',
    'normal',                 'communications interrupted',
    'resolution interrupted', 'potential conflict',
    'recover',                'recover done',
    'shutdown',               'paused',
    'startup',                'recover wait',
);
our @states = qw/
    na free active expired released
    abandoned reset backup reserved bootp
/;

my $MAC_REGEX = '^'. join(':', (q{[0-9a-f]{1,2}}) x 6) . '$';

=head1 TYPES

=head2 HexInt

=head2 Ip

=head2 Mac

=head2 State

=head2 FailoverState

=head2 Timei

=head2 ConfigObject

=head2 LeasesObject

=head2 OMAPIObject

=head2 Statements

=cut

declare State,
    as Str,
    constraint => quote_sub q{ my $s = $_; grep { $s eq $_ } @Net::ISC::DHCPd::Types::states };

declare FailoverState,
    as Str,
    constraint => quote_sub q{ my $s = $_; grep { $s eq $_ } @Net::ISC::DHCPd::Types::failover_states };

declare Mac, as StrMatch[qr/$MAC_REGEX/i];
declare Ip, as StrMatch[qr/^[\d\.]+$/];
declare Statements, as StrMatch[qr/^[\w,]+$/];
declare ConfigObject,
    as InstanceOf['Net::ISC::DHCPd::Config'];
declare LeasesObject,
    as InstanceOf['Net::ISC::DHCPd::Leases'];
declare OMAPIObject,
    as InstanceOf['Net::ISC::DHCPd::OMAPI'];

# these are strictly needed for their coercions
declare HexInt, as Int;
declare Timei, as Int;

# coercions
# we will probably want to change these to declare_coercion so that we can use
# them electively later.

coerce State,
    from Int, q{ $Net::ISC::DHCPd::Types::states[$_] };

coerce HexInt,
    from Str, q{ s/://g; hex $_ };

coerce Ip,
    from Str, q{ join '.', map { hex $_ } split /:/ };


coerce Mac,
    from Str, q{
            my @mac = split /[\-\.:]/;
            my $format = scalar @mac == 3 ? '%04s' : '%02s';
            my $str = join '', map { sprintf $format, $_ } @mac; # fix single digits 0:x:ff:00:00:01
            # the following line handles mac addresses in the format of 123456789101
            # or any other weirdness the above didn't take care of.
            $_ = $str;
            join ':', /(\w\w)/g; # rejoin with colons
    };

coerce Timei,
    from Str, q{ s/://g; hex $_ };

coerce Statements,
    from Str, q{ s/\s+/,/g; $_; },
    from ArrayRef, q{ join ",", @$_ };

coerce ConfigObject, from HashRef, q{
    eval "require Net::ISC::DHCPd::Config" or die $@;
    Net::ISC::DHCPd::Config->new($_);
};

coerce LeasesObject, from HashRef, q{
    eval "require Net::ISC::DHCPd::Leases" or die $@;
    Net::ISC::DHCPd::Leases->new($_);
};

coerce OMAPIObject, from HashRef, q{
    eval "require Net::ISC::DHCPd::OMAPI" or die $@;
    Net::ISC::DHCPd::OMAPI->new($_);
};

=head2 from_State

=cut

sub from_State {
    my $self = shift;
    my $attr = shift;
    my $value = $self->$attr or return 0;

    for my $i (0..@states) {
        return $i if($states[$i] eq $value);
    }

    return 0;
}

=head2 from_FailoverState

=cut

sub from_FailoverState {
    my $self = shift;
    my $attr = shift;
    my $value = $self->$attr or return 0;

    for my $i (0..@failover_states) {
        return $i if($failover_states[$i] eq $value);
    }

    return 0;
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

__PACKAGE__->meta->make_immutable;

1;
