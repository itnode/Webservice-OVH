package Webservice::OVH::Domain::Service;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

sub _new {

    my ( $class, $api_wrapper, $service_name ) = @_;

    croak "Missing service_name" unless $service_name;

    my $self = bless { _api_wrapper => $api_wrapper, _name => $service_name, _owner => undef, _service_info => undef, _properties => undef }, $class;

    return $self;
}

sub service_infos {

    my ($self) = @_;

    my $api                   = $self->{_api_wrapper};
    my $service_name          = $self->name;
    my $response_service_info = $api->rawCall( method => 'get', path => "/domain/$service_name/serviceInfos", noSignature => 0 );

    croak $response_service_info->error if $response_service_info->error;

    $self->{_service_info} = $response_service_info->content;

    return $self->{_service_info};
}

sub properties {

    my ($self) = @_;

    my $api                 = $self->{_api_wrapper};
    my $service_name        = $self->name;
    my $response_properties = $api->rawCall( method => 'get', path => "/domain/$service_name", noSignature => 0 );

    croak $response_properties->error if $response_properties->error;

    $self->{_properties} = $response_properties->content;

    return $self->{_properties};
}

sub name {

    my ($self) = @_;

    return $self->{_name};
}

sub owner {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $properties = $self->{_properties} || $self->properties;
    my $owner_id   = $properties->{whoisOwner};
    my $owner      = $self->{_owner} = $self->{_owner} || Webservice::OVH::Me::Contact->_new_existing( $api, $owner_id );

    return $self->{_owner};
}

sub change_contact {

    my ( $self, $new_contact ) = @_;

    croak "Missing new_contact" unless $new_contact;

    my $api          = $self->{_api_wrapper};
    my $service_name = $self->name;
    my $response     = $api->rawCall( method => 'post', path => "/domain/$service_name/changeContact", body => { contactBilling => $new_contact }, noSignature => 0 );

    croak $response->error if $response->error;

    return $response->content;
}

1;
