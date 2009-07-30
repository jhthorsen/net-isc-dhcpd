package Net::ISC::DHCPd::OMAPI::Meta::Class;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Meta::Class

=head1 SYNOPSIS

 use Net::ISC::DHCPd::OMAPI::Meta::Class; # not use Moose

 omapi_attr foo => (
    isa => State,
 );

 # ...

 1;

=cut

use Moose;
use Moose::Exporter;
use MooseX::Types -declare => [qw/HexInt Ip Mac State Time/];
use MooseX::Types::Moose ':all';

my @types;
my @states = qw/na free active expired released
                abandoned reset backup reserved bootp/;

=head1 MOOSE TYPES

=head2 State

=head2 HexInt

=head2 Ip

=head2 Mac

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
    from Str, via { s/://g; return hex },
);

coerce Time, (
    from Str, via { s/://g; return hex },
);

coerce Ip, (
    from Str, via { join ".", map { hex $_ } split /:/ },
);

=head1 FUNCTIONS

=head2 omapi_attr

 omapi_attr $name => %attr;

C<%attr> is by default:

 (
   is => "rw",
   predicate => "has_$name",
   traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
 )

It will also set "coerce => 1", when "isa" is one of L<MOOSE TYPES>.

=cut

sub omapi_attr {
    my $class = shift;
    my $name  = shift;
    my %opts  = @_;

    for my $isa (State, HexInt, Time, Ip) {
        if($opts{'isa'} eq $isa) {
            $opts{'coerce'} = 1;
            last;
        }
    }

    $class->meta->add_attribute($name => (
        is => 'rw',
        predicate => "has_$name",
        traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
        %opts,
    ));
}

Moose::Exporter->setup_import_methods(
    with_caller => [qw/omapi_attr/],
    as_is => [qw/HexInt Ip Mac State Time/],
    also => 'Moose',
);

=head1 AUTHOR

See L<Net::ISC::DHCPd>

=cut

1;
