package Net::ISC::DHCPd::OMAPI::Meta::Class;

=head1 NAME

Net::ISC::DHCPd::OMAPI::Meta::Class - Sugar for omapi classes

=head1 SYNOPSIS

 use Net::ISC::DHCPd::OMAPI::Meta::Class; # not use Moose

 omapi_attr foo => (
    isa => State,
 );

=cut

use Moose;
use Net::ISC::DHCPd::Types ':all';
use Moose::Exporter;

my @types = Net::ISC::DHCPd::Types->get_type_list;

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
    my $names = ref $_[0] eq 'ARRAY' ? shift : [shift];
    my %opts  = @_;

    if(my $isa = $opts{'isa'}) {
        $isa =~ s/Net::ISC::DHCPd::Types:://;
        if(__PACKAGE__->can("to_$isa")) {
            $opts{'coerce'} = 1;
        }
    }

    for my $name (@$names) {
        $class->meta->add_attribute($name => (
            is => 'rw',
            predicate => "has_$name",
            traits => [qw/Net::ISC::DHCPd::OMAPI::Meta::Attribute/],
            %opts,
        ));
    }
}

Moose::Exporter->setup_import_methods(
    with_caller => [qw/omapi_attr/],
    as_is => \@types,
    also => 'Moose',
);

=head1 AUTHOR

See L<Net::ISC::DHCPd>

=cut

1;
