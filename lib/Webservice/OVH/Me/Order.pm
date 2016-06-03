package Webservice::OVH::Me::Order;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Order::Detail;

sub _new {

    my ( $class, $api_wrapper, $order_id ) = @_;

    die "Missing order_id" unless $order_id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/order/$order_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $order_id, _properties => $porperties, _details => {} }, $class;

    return $self;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub date {
    
    my ($self) = @_;
    
    my $str_datetime = $self->{_properties}->{date};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub expiration_date {
    
    my ($self) = @_;
    
    my $str_datetime = $self->{_properties}->{expirationDate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub password {
    
    my ($self) = @_;
    
    return $self->{_properties}->{password};
}

sub pdf_url {
    
    my ($self) = @_;
    
    return $self->{_properties}->{pdfUrl};
}

sub price_without_tax {
    
    my ($self) = @_;
    
    return $self->{_properties}->{priceWithoutTax};
}

sub price_with_tax {
    
    my ($self) = @_;
    
    return $self->{_properties}->{priceWithTax};
}

sub tax {
    
    my ($self) = @_;
    
    return $self->{_properties}->{tax};
}

sub url {
    
    my ($self) = @_;
    
    return $self->{_properties}->{url};
}


sub associated_object {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/associatedObject", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub available_registered_payment_mean {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/availableRegisteredPaymentMean", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub bill {

    my ($self, $module) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    #my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/bill", noSignature => 0 );
    #croak $response->error if $response->error;
    
    my $object = $self->associated_object;
    
    if( $object->{type} eq 'Bill' ) {
        
        my $bill = $module->me->bill( $object->{id} );
        
        return $bill;
    } else {
        
        return undef;
    }
}

sub details {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/details", noSignature => 0 );
    croak $response->error if $response->error;

    my $detail_ids = $response->content;
    my $details    = [];

    foreach my $detail_id (@$detail_ids) {

        my $detail = $self->{_details}{$detail_id} = $self->{_details}{$detail_id} || Webservice::OVH::Me::Order::Detail->_new( $api, $self, $detail_id );
        push @$details, $detail;
    }

    return $details;
}

sub detail {

    my ( $self, $detail_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $detail = $self->{_details}{$detail_id} = $self->{_details}{$detail_id} || Webservice::OVH::Me::Order::Detail->_new( $api, $self, $detail_id );

    return $detail;
}

sub payment {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/payment", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub payment_means {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/paymentMeans", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub pay_with_registered_payment_mean {

    my ( $self, $payment_mean ) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'post', path => "/me/order/$order_id/payWithRegisteredPaymentMean", body => { paymentMean => $payment_mean }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub status {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $order_id = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/order/$order_id/status", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

1;
