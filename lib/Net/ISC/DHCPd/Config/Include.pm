package Net::ISC::DHCPd::Config::Include;

=head1 NAME

Net::ISC::DHCPd::Config::Include - Hold content of included file

=head1 DESCRIPTION

See L<Net::ISC::DHCPd::Config::Role> for methods and attributes without
documentation.

=head1 SYNOPSIS

See L<Net::ISC::DHCPd::Config> for synopsis.

=cut

use Moose;
use Path::Class::File;

with 'Net::ISC::DHCPd::Config::Root';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Function
    Net::ISC::DHCPd::Config::OptionSpace
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::KeyValue
/);

=head2 filehandle

This attribute has a builder, which handles relative paths.
This might be changed in the future, if proven to be wrong.

=cut

sub _build_filehandle { shift->file->openr }
sub _build_regex { qr{^\s* include \s "([^"]+)" ;}x }

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    my $self = shift;

    return {
        file => Path::Class::File->new($_[0]),
        root => $self->root,
        parent => $self,
    };
}

=head2 generate

=cut

sub generate {
    return sprintf q(include "%s";), shift->file;
}

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
