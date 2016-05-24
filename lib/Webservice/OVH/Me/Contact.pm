package Webservice::OVH::Me::Contact;

use strict;
use warnings;

our $VERSION = 0.1;

sub _new_existing {

    my ( $class, $api_wrapper, $contact_id ) = @_;

    die "Missing contact_id" unless $contact_id;

    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/contact/$contact_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $id         = $response->content->{id};
    my $porperties = $response->content;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $id, _properties => $porperties }, $class;

    return $self;
}

sub _new {
    
    
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;
    
    my $api = $self->{_api_wrapper};
    my $contact_id = $self->{_id};
    my $response = $api->rawCall( method => 'get', path => "/me/contact/$contact_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;

    return $self->{_properties};
}

1;
