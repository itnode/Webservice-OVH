package Webservice::OVH::Order::Email::Domain;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {
    
    my ( $class, $api_wrapper ) = @_;
    
    my $self = bless { _api_wrapper => $api_wrapper}, $class;

    return $self;
}

sub available_services {
    
    my ($self) = @_;
    
    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/order/email/domain", noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub allowed_durations {
    
    my ($self, $domain, $offer) = @_;
    
    croak "Missing offer" unless $offer;
    croak "Missing domain" unless $domain;
    
    my $filter = Webservice::OVH::Helper->construct_filter( "domain" => $domain, "offer" => $offer );
    
    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/order/email/domain/new$filter", noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub info {
    
    my ($self, $domain, $offer, $duration) = @_;
    
    croak "Missing offer" unless $offer;
    croak "Missing duration" unless $duration;
    croak "Missing domain" unless $domain;
    
    my $filter = Webservice::OVH::Helper->construct_filter( "domain" => $domain, "offer" => $offer );
    
    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => sprintf("/order/email/domain/new/%s%s", $duration, $filter), noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub new {
    
    my ($self, $module, $domain, $offer, $duration) = @_;
    
    croak "Missing offer" unless $offer;
    croak "Missing duration" unless $duration;
    croak "Missing domain" unless $domain;
    
    my $api = $self->{_api_wrapper};
    my $body = { offer => $offer, domain => $domain };
    my $response = $api->rawCall( method => 'post', path => "/order/email/domain/new/$duration", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
    
    my $order = $module->me->order($response->content->{orderId});
    
    return $order;
}


1;