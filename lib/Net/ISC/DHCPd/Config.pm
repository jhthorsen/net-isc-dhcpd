package Net::ISC::DHCPd::Config;

=head1 NAME 

Net::ISC::DHCPd::Config - Parse and create ISC DHCPd config

=cut

use Moose;

with 'Net::ISC::DHCPd::Config::Root';

__PACKAGE__->create_children(qw/
    Net::ISC::DHCPd::Config::Host
    Net::ISC::DHCPd::Config::Subnet
    Net::ISC::DHCPd::Config::SharedNetwork
    Net::ISC::DHCPd::Config::Function
    Net::ISC::DHCPd::Config::OptionSpace
    Net::ISC::DHCPd::Config::Option
    Net::ISC::DHCPd::Config::Include
    Net::ISC::DHCPd::Config::KeyValue
/);

sub _build_root { $_[0] }
sub _build_regex { qr{\x00} } # should not be used

=head1 METHODS

=head2 filehandle

This method will be deprecated.

=cut

sub filehandle {
    Carp::cluck('->filehandle is replaced with private attribute _filehandle');
    shift->_filehandle;
}

=head1 AUTHOR

Jan Henning Thorsen

=cut

1;
