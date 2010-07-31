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

sub _build_regex { qr{^\s* include \s "([^"]+)" ;}x }

sub _build__filehandle {
    my $self = shift;
    my $file = $self->file;

    if($file->is_relative and !-e $file) {
        $file = Path::Class::File->new($self->root->file->dir, $file);
    }

    return $file->openr;
}

=head1 METHODS

=head2 captured_to_args

=cut

sub captured_to_args {
    my $self = shift;
    my $file = shift;

    return {
        file => $file,
        parent => $self,
        root => $self,
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
