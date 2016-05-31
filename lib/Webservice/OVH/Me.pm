package Webservice::OVH::Me;

use strict;
use warnings;
use Carp qw{ carp croak };
use Webservice::OVH::Helper;

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;
use Webservice::OVH::Me::Order;
use Webservice::OVH::Me::Bill;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _contacts => {}, _tasks_contact_change => {}, _orders => {}, _bills => {} }, $class;

    return $self;
}

sub contacts {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/contact", noSignature => 0 );
    croak $response->error if $response->error;

    my $contact_ids = $response->content;
    my $contacts    = [];

    foreach my $contact_id (@$contact_ids) {

        my $contact = $self->{_contacts}{$contact_id} = $self->{_contacts}{$contact_id} || Webservice::OVH::Me::Contact->_new_existing( $api, $contact_id );
        push @$contacts, $contact;
    }

    return $contacts;
}

sub contact {

    my ( $self, $contact_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $contact = $self->{_contacts}{$contact_id} = $self->{_contacts}{$contact_id} || Webservice::OVH::Me::Contact->_new_existing( $api, $contact_id );

    return $contact;
}

sub tasks_contact_change {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/task/contactChange", noSignature => 0 );
    croak $response->error if $response->error;

    my $task_ids = $response->content;
    my $tasks    = [];

    foreach my $task_id (@$task_ids) {

        my $task = $self->{_tasks_contact_change}{$task_id} = $self->{_tasks_contact_change}{$task_id} || Webservice::OVH::Me::Task->_new( $api, "contact_change", $task_id );
        push @$tasks, $task;
    }

    return $tasks;
}

sub task_contact_change {

    my ( $self, $task_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $task = $self->{_tasks_contact_change}{$task_id} = $self->{_tasks_contact_change}{$task_id} || Webservice::OVH::Me::Task->_new( $api, "contact_change", $task_id );

    return $task;

}

sub orders {

    my ( $self, $date_from, $date_to ) = @_;

    my $str_date_from = $date_from ? $date_from->strftime("%Y-%m-%d") : "";
    my $str_date_to   = $date_to   ? $date_to->strftime("%Y-%m-%d")   : "";
    my $filter = Webservice::OVH::Helper->construct_filter( "date.from" => $str_date_from, "date.to" => $str_date_to );

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/order$filter", noSignature => 0 );
    croak $response->error if $response->error;

    my $order_ids = $response->content;
    my $orders    = [];

    foreach my $order_id (@$order_ids) {

        my $order = $self->{_orders}{$order_id} = $self->{_orders}{$order_id} || Webservice::OVH::Me::Order->_new( $api, $order_id );
        push @$orders, $order;
    }

    return $orders;
}

sub order {

    my ( $self, $order_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $order = $self->{_orders}{$order_id} = $self->{_orders}{$order_id} || Webservice::OVH::Me::Order->_new( $api, $order_id );

    return $order;
}

sub bill {

    my ( $self, $bill_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $bill = $self->{_bills}{$bill_id} = $self->{_bills}{$bill_id} || Webservice::OVH::Me::Bill->_new( $api, $bill_id );

    return $bill;
}

sub bills {

    my ( $self, $date_from, $date_to ) = @_;

    my $str_date_from = $date_from ? $date_from->strftime("%Y-%m-%d") : "";
    my $str_date_to   = $date_to   ? $date_to->strftime("%Y-%m-%d")   : "";
    my $filter = Webservice::OVH::Helper->construct_filter( "date.from" => $str_date_from, "date.to" => $str_date_to );

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => sprintf("/me/bill%s", $filter), noSignature => 0 );
    croak $response->error if $response->error;

    my $bill_ids = $response->content;
    my $bills    = [];

    foreach my $bill_id (@$bill_ids) {

        my $bill = $self->{_bills}{$bill_id} = $self->{_bills}{$bill_id} || Webservice::OVH::Me::Bill->_new( $api, $bill_id );
        push @$bills, $bill;
    }

    return $bills;
}


1;
