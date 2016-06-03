package Webservice::OVH::Order::Hosting::Web;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper }, $class;

    return $self;
}

sub free_email_info {

    my ( $self, $domain ) = @_;

    croak "Missing domain" unless $domain;
    my $offer = "START";

    my $filter            = Webservice::OVH::Helper->construct_filter( "domain" => $domain, "offer" => $offer );
    my $api               = $self->{_api_wrapper};
    my $response_duration = $api->rawCall( method => 'get', path => "/order/hosting/web/new$filter", noSignature => 0 );
    croak $response_duration->error if $response_duration->error;
    my $duration = $response_duration->content->[0];

    my $filter2 = Webservice::OVH::Helper->construct_filter( "domain" => $domain, "offer" => $offer );
    my $response = $api->rawCall( method => 'get', path => sprintf( "/order/hosting/web/new/%s%s", $duration, $filter2 ), noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub activate_free_email {

    my ( $self, $domain, $module ) = @_;

    croak "Missing domain" unless $domain;
    my $offer    = 'START';
    my $dns_zone = 'NO_CHANGE';

    my $filter            = Webservice::OVH::Helper->construct_filter( "domain" => $domain, "offer" => $offer );
    my $api               = $self->{_api_wrapper};
    my $response_duration = $api->rawCall( method => 'get', path => sprintf( "/order/hosting/web/new%s", $filter ), noSignature => 0 );
    croak $response_duration->error if $response_duration->error;
    my $duration = $response_duration->content->[0];

    my $body = { domain => $domain, offer => 'START', dnsZone => $dns_zone };
    my $response = $api->rawCall( method => 'post', path => "/order/hosting/web/new/$duration", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
    
    my $order = $module->me->order($response->content->{orderId});
    
    $order->pay_with_registered_payment_mean('fidelityAccount');

    return $order;
}

1;
