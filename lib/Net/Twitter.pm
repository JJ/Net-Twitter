package Net::Twitter;
use Moose;
extends 'Net::Twitter::Base';

use namespace::autoclean;

with $_ for qw/
    Net::Twitter::API::REST
    Net::Twitter::API::Search
    Net::Twitter::API::TwitterVision
/;

has _error  => (
    isa       => 'Net::Twitter::Error',
    is        => 'rw',
    clearer   => '_clear_error',
    predicate => 'has_error',
);

sub BUILDARGS {
    my ($class, %options) = @_;

    if ( delete $options{identica} ) {
        %options = (
            apiurl => 'http://identi.ca/api',
            apihost => 'identi.ca:80',
            apirealm => 'Laconica API',
            %options,
        );
    }
    return $class->SUPER::BUILDARGS(%options);
}

# Legacy Net::Twitter does not make the call unless twittervision is true
around 'update_twittervision' => sub {
    my $next = shift;
    my $self = shift;
    
    return unless $self->twittervision;

    return $next->($self, @_);
};

sub http_message {
    my $self = shift;

    return unless $self->has_error;
    return $self->_error->message;
}

sub http_code {
    my $self = shift;

    return unless $self->has_error;
    return $self->_error->code;
}

sub get_error {
    my $self = shift;

    return unless $self->has_error;

    return $self->_error->has_twitter_error
        ? $self->_error->twitter_error
        : {
            request => undef,
            error   => "TWITTER RETURNED ERROR MESSAGE BUT PARSING OF JSON RESPONSE FAILED - "
                       . $self->_error->message
          }; 
}

sub parse_result {
    my $self = shift;

    $self->_clear_error;

    my $r = eval { $self->next::method(@_) };
    if ( $@ ) {
        die $@ unless UNIVERSAL::isa($@, 'Net::Twitter::Error');

        $self->_error($@);
    }

    return $r;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

Net::Twitter - A Net::Twitter compatibility layer

=head1 SYNOPSIS

    use Net::Twitter;

    my $nt = Net::Twitter->new(username => $username, password => $password);

    my $followers = $nt->followers;
    if ( !followers ) {
        warn $nt->http_message;
    }

=head1 DESCRIPTION

This module provides a B<Net::Twitter> compatibility layer for
Net::Twitter.  Net::Twitter::Base throws exceptions for Twitter API and
network errors.  This module catches those errors returning C<undef> to the
caller, instead.  It provides L</"get_error">, L</"http_code"> and
L</"http_message">, like Net::Twitter, for accessing that error information.

This module is provided to make it easy to test or migrate applications to
Net::Twitter::REST.

This module does not provide full compatibility with Net::Twitter.  It does not,
for example, provided C<update_twittervision> or the Twitter Search API
methods. (See L<Net::Twitter::Search> for Net::Twitter::Lite's answer to
answer to the latter.

=head1 METHODS

=over 4

=item new

This method takes the same parameters as L<Net::Twitter::Base/new>.

=item get_error

Returns the HTTP response content for the most recent API method call if it ended in error.

=item http_code

Returns the HTTP response code the most recent API method call if it ended in error.

=item http_message

Returns the HTTP message for the most recent API method call if it ended in error.

=back

=head1 SEE ALSO

=over 4

=item L<Net::Twitter::Base>

This is the base class for Net::Twitter::Compat.  See its documentation
for more details.

=back

=head1 AUTHOR

Marc Mims <marc@questright.com>

=head1 LICENSE

Copyright (c) 2009 Marc Mims

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
