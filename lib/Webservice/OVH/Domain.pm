package Webservice::OVH::Domain;

use strict;
use warnings;

our $VERSION = 0.1;

use Carp qw{ carp croak };

use Webservice::OVH::Domain::Service;
use Webservice::OVH::Domain::Zone;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _services => {}, _zones => {} }, $class;

    return $self;
}

sub services {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/domain", noSignature => 0 );
    croak $response->error if $response->error;

    my $service_array = $response->content;
    my $services      = [];

    foreach my $service_name (@$service_array) {

        my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Domain::Service->_new( $api, $service_name );
        push @$services, $service;
    }

    return $services;
}

sub zones {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/domain/zone", noSignature => 0 );
    croak $response->error if $response->error;

    my $zone_names = $response->content;
    my $zones = [];
    
    foreach my $zone_name (@$zone_names) {

        my $zone = $self->{_zones}{$zone_name} = $self->{_zones}{$zone_name} || Webservice::OVH::Domain::Zone->_new( $api, $zone_name );
        push @$zones, $zone;
    }

    return $zones;
}

sub service {

    my ( $self, $service_name ) = @_;

    my $api = $self->{_api_wrapper};
    my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Domain::Service->_new( $api, $service_name );
    return $service;
}

sub zone {

    my ( $self, $zone_name ) = @_;

    my $api = $self->{_api_wrapper};
    my $zone = $self->{_zones}{$zone_name} = $self->{_zones}{$zone_name} || Webservice::OVH::Domain::Zone->_new( $api, $zone_name );

    return $zone;
}

1;
