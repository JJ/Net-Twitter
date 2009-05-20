package Net::Twitter::API::TwitterVision;
use Moose::Role;
use Net::Twitter::API;

has twittervision => ( isa => 'Bool', is => 'rw', default => 0 );
has tvurl         => ( isa => 'Str',  is => 'ro', default => 'http://twittervision.com' );
has tvhost        => ( isa => 'Str',  is => 'ro', default => 'twittervision.com:80'     );
has tvrealm       => ( isa => 'Str',  is => 'ro', default => 'Web Password'             );

requires qw/ua username password/;

after credentials => sub {
    my $self = shift;

    $self->ua->credentials($self->tvhost, $self->tvrealm, $self->username, $self->password);
};

base_url 'tvurl';

twitter_api_method current_status => (
    description => <<'',
Get the current location and status of a user.

    path     => 'user/current_status/id',
    method   => 'GET',
    params   => [qw/id callback/],
    required => [qw/id/],
    returns  => 'HashRef',
);

twitter_api_method update_twittervision => (
    description => <<'',
Updates the location for the authenticated user.

    path     => 'user/update_location',
    method   => 'POST',
    params   => [qw/location/],
    required => [qw/location/],
    returns  => 'HashRef',
);

1;
