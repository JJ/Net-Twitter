#!perl
use warnings;
use strict;
use Test::More tests => 4;
use Test::Exception;
use lib qw(t/lib);
use Mock::LWP::UserAgent;
use Net::Twitter::Lite;

my $nt = Net::Twitter::Lite->new(
    username => 'NTLite',
    password => 'secret',
);

my $ua = $nt->_ua;

# things that should fail
throws_ok { $nt->relationship_exists(qw/one two three/) } qr/expected 2 args/, 'too many args';
throws_ok {
    Net::Twitter::Lite->new(useragent_class => 'NoSuchModule::Test7701')
} qr/Can't locate NoSuchModule/, 'bad useragent_class';
throws_ok { $nt->show_status([ 123 ]) } qr/expected a HashRef/, 'wrong ref type';
throws_ok { $nt->friends({ count => 30, page => 4 }, 'extra') }
        qr/Too many args/, 'extra args';

exit 0;
