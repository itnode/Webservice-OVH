package Webservice::OVH::Domain;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Domain::Service;
use Webservice::OVH::Domain::Zone;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _services => {}, _zones => {}, _aviable_services => [], _aviable_zones => [] }, $class;

    return $self;
}

sub service_exists {

    my ( $self, $service_name, $recheck_list ) = @_;

    if ($recheck_list) {

        my $api = $self->{_api_wrapper};
        my $response = $api->rawCall( method => 'get', path => "/domain", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $service_name } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_aviable_services};

        return ( grep { $_ eq $service_name } @$list ) ? 1 : 0;
    }
}

sub zone_exists {

    my ( $self, $zone_name, $recheck_list ) = @_;

    if ($recheck_list) {

        my $api = $self->{_api_wrapper};
        my $response = $api->rawCall( method => 'get', path => "/domain/zone", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $zone_name } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_aviable_zones};

        return ( grep { $_ eq $zone_name } @$list ) ? 1 : 0;
    }
}

sub services {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/domain", noSignature => 0 );
    croak $response->error if $response->error;

    my $service_array = $response->content;
    my $services      = [];
    $self->{_aviable_services} = $service_array;

    foreach my $service_name (@$service_array) {
        if ( $self->service_exists($service_name) ) {
            my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Domain::Service->_new( $api, $service_name );
            push @$services, $service;
        }
    }

    return $services;
}

sub zones {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/domain/zone", noSignature => 0 );
    croak $response->error if $response->error;

    my $zone_names = $response->content;
    my $zones      = [];
    $self->{_aviable_zones} = $zone_names;

    foreach my $zone_name (@$zone_names) {

        if ( $self->zone_exists($zone_name) ) {
            my $zone = $self->{_zones}{$zone_name} = $self->{_zones}{$zone_name} || Webservice::OVH::Domain::Zone->_new( $api, $zone_name );
            push @$zones, $zone;
        }
    }

    return $zones;
}

sub service {

    my ( $self, $service_name ) = @_;

    if ( $self->service_exists( $service_name, 1 ) ) {

        my $api = $self->{_api_wrapper};
        my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Domain::Service->_new( $api, $service_name );

        return $service;
    } else {

        carp "Service $service_name doesn't exists";
        return undef;
    }
}

sub zone {

    my ( $self, $zone_name ) = @_;

    if ( $self->zone_exists( $zone_name, 1 ) ) {

        my $api = $self->{_api_wrapper};
        my $zone = $self->{_zones}{$zone_name} = $self->{_zones}{$zone_name} || Webservice::OVH::Domain::Zone->_new( $api, $zone_name );

        return $zone;

    } else {

        carp "Zone $zone_name doesn't exists";
        return undef;
    }

}

1;
