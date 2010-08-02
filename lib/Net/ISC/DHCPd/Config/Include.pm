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

=head1 ATTRIBUTES

=head2 generate_with_include

This attribute holds a boolean value. L</generate> will result in

    include "path/from/file/attribute";

when false, and the included config if true. This attribute is false
by default.

=cut

has generate_with_include => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

sub _build_regex { qr{^\s* include \s "([^"]+)" ;}x }
sub _build_root { shift->parent }

sub _build__filehandle {
    my $self = shift;
    my $file = $self->file;

    if($file->is_relative and !-e $file) {
        $file = Path::Class::File->new($self->root->file->dir, $file);
    }

    return $file->openr;
}

=head1 METHODS

=head2 parse

This around method modifier will stop the parser when parsing
recursively, which will require the user to manually parse the
included files from the config. Reason for this is that the
C<parse()> method returns the number of lines in a single file.
and counting lines from included files will break this behaviour.

See also L<Net::ISC::DHCPd::Config::Role/parse> and
L<Net::ISC::DHCPd::Config/SYNOPSIS>.

=cut

around parse => sub {
    my $next = shift;
    my $self = shift;

    if($_[0] and $_[0] eq 'recursive') {
        return '0e0';
    }

    return $self->$next(@_);
};

=head2 captured_to_args

See L<Net::ISC::DHCPd::Config::Role/captured_to_args>.

=cut

sub captured_to_args {
    return { file => $_[1] };
}

=head2 generate

This method can either result in C<include ...;> or the whole
config of the included file. See L</generate_with_include> for how
to control the behaviour.

See also L<Net::ISC::DHCPd::Config::Role/generate>.

=cut

sub generate {
    my $self = shift;

    if($self->generate_with_include) {
        my $text = $self->generate_config_from_children;
        return $text ? $text : "# forgot to parse " .$self->file ."?";

    }
    else {
        return qq(include ") .$self->file .qq(";);
    }
}

=head1 COPYRIGHT & LICENSE

=head1 AUTHOR

See L<Net::ISC::DHCPd>.

=cut

1;
