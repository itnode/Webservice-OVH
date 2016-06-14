package Webservice::OVH::Order::Domain::Zone;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Order;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper }, $class;

    return $self;
}

sub existing {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};

    my $response = $api->rawCall( method => 'get', path => "/order/domain/zone", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub info_order {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};

    my $response = $api->rawCall( method => 'get', path => "/order/domain/zone/new", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub order {

    my ( $self, $module, $zone_name ) = @_;

    my $api = $self->{_api_wrapper};

    my $response = $api->rawCall( method => 'post', path => "/order/domain/zone/new", body => { zoneName => $zone_name }, noSignature => 0 );
    croak $response->error if $response->error;

    my $order = $module->me->order( $response->content->{orderId} );

    return $order;
}

sub options {

    my ( $self, $zone_name ) = @_;

    my $api = $self->{_api_wrapper};

    my $response = $api->rawCall( method => 'get', path => "/order/domain/zone/$zone_name", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

1;
