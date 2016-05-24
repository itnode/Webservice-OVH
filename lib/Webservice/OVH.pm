package Webservice::OVH;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use OvhApi;
use Webservice::OVH::Domain;
use Webservice::OVH::Me;
use Webservice::OVH::Order;

# Class variables

# End - Class variables

sub new {

    my ( $class, %params ) = @_;

    my @keys = qw{ application_key application_secret consumer_key };

    if ( my @missing_parameters = grep { not $params{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $api_wrapper = OvhApi->new( 'type' => "https://eu.api.ovh.com/1.0", applicationKey => $params{application_key}, applicationSecret => $params{application_secret}, consumerKey => $params{consumer_key} );
    my $domain      = Webservice::OVH::Domain->new($api_wrapper);
    my $me          = Webservice::OVH::Me->new($api_wrapper);
    my $order       = Webservice::OVH::Order->new($api_wrapper);

    OvhApi->setRequestTimeout( timeout => $params{timeout} || 120 );

    my $self = bless {}, $class;

    $self->{_domain}      = $domain;
    $self->{_me}          = $me;
    $self->{_order}       = $order;
    $self->{_api_wrapper} = $api_wrapper;

    return $self;
}

sub set_timeout {

    my ( $class, $timeout ) = @_;

    OvhApi->setRequestTimeout( timeout => $timeout );
}

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

sub me {

    my ($self) = @_;

    return $self->{_me};
}

sub order {

    my ($self) = @_;

    return $self->{_order};
}

1;
