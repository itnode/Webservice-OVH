package Webservice::OVH::Me::Bill;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Order;

sub _new {

    my ( $class, $api_wrapper, $bill_id ) = @_;

    die "Missing bill_id" unless $bill_id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/bill/$bill_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;
    my $order_id   = $porperties->{orderId};

    my $self = bless { _api_wrapper => $api_wrapper, _id => $bill_id, _properties => $porperties, _order_id => $order_id }, $class;

    return $self;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub order {

    my ( $self, $module ) = @_;

    my $api = $self->{_api_wrapper};

    my $order_id = $self->{_order_id};
    my $order    = $module->me->order($order_id);
    return $order;

}

sub properties {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $bill_id  = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/me/bill/$bill_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_properties} = $response->content;
    return $self->{_properties};
}

1;
