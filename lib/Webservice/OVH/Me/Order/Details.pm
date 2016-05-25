package Webservice::OVH::Me::Order::Detail;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {

    my ( $class, $api_wrapper, $order, $detail_id ) = @_;
    
    die "Missing detail_id" unless $detail_id;
    my $order_id = $order->id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/order/$order_id/details/$detail_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    my $porperties = $response->content;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $detail_id, _properties => $porperties, _order => $order }, $class;

    return $self;
}

sub order {
    
    my ($self) = @_;
    
    return $self->{_order};
}

sub id {
    
    my ($self) = @_;
    
    return $self->{_id};
}

sub properties {
    
    my ($self) = @_;
    
    my $api = $self->{_api_wrapper};
    my $order_id = $self->{_order}->id;
    my $detail_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/details/$detail_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

1;
