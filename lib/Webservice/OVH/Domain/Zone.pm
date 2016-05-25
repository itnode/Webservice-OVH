package Webservice::OVH::Domain::Zone;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Domain::Zone::Record;

sub _new {

    my ( $class, $api_wrapper, $zone_name ) = @_;

    croak "Missing zone_name" unless $zone_name;

    my $self = bless { _api_wrapper => $api_wrapper, _name => $zone_name, _service_info => undef, _properties => undef, _records => {} }, $class;

    return $self;
}

sub service_infos {

    my ($self) = @_;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $response  = $api->rawCall( method => 'get', path => "/domain/zone/$zone_name/serviceInfos", noSignature => 0 );

    croak $response->error if $response->error;

    $self->{_service_info} = $response->content;

    return $self->{_service_info};
}

sub properties {

    my ($self) = @_;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $response  = $api->rawCall( method => 'get', path => "/domain/zone/$zone_name", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_properties} = $response->content;

    return $self->{_properties};
}

sub records {

    my ( $self, %filter ) = @_;

    my $filter_type      = $filter{type} || "";
    my $filter_subdomain = $filter{subdomain} || "";
    
    my $filter_vars = "";
    $filter_vars = sprintf("?fieldType=%s&subDomain=%s", $filter_type, $filter_subdomain) if $filter_type && $filter_subdomain;
    $filter_vars = sprintf("?fieldType=%s", $filter_type) if $filter_type && !$filter_subdomain;
    $filter_vars = sprintf("?subDomain=%s", $filter_subdomain) if !$filter_type && $filter_subdomain;
    

    my $api = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $response = $api->rawCall( method => 'get', path => "/domain/zone/$zone_name/record$filter_vars", noSignature => 0 );
    croak $response->error if $response->error;

    my $record_ids = $response->content;
    my $records    = [];

    foreach my $record_id (@$record_ids) {

        my $record = $self->{_records}{$record_id} = $self->{_records}{$record_id} || Webservice::OVH::Domain::Zone::Record->_new_existing( $api, $self, $record_id );
        push @$records, $record;
    }

    return $records;
}

sub record {

    my ( $self, $record_id ) = @_;
    
    croak "Missing record_id" unless $record_id;
    
    my $api = $self->{_api_wrapper};
    my $record = $self->{_records}{$record_id} = $self->{_records}{$record_id} || Webservice::OVH::Domain::Zone::Record->_new_existing( $api, $self, $record_id );
    
    return $record;
}

sub new_record {

    my ( $self, %params ) = @_;
    
    my $api = $self->{_api_wrapper};
    my $record = Webservice::OVH::Domain::Zone::Record->_new($api, $self, %params);

    return undef;
}

sub name {
    
    my ( $self ) = @_;
    
    return $self->{_name};
}

sub change_contact {

    my ( $self, %params ) = @_;
    
    croak "at least one parameter needed: contact_billing contact_admin contact_tech" unless %params;

    my $api          = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $body = {};
    $body->{contactBilling} = $params{contact_billing} if exists $params{contact_billing};
    $body->{contactAdmin} = $params{contact_admin} if exists $params{contact_admin};
    $body->{contactTech} = $params{contact_tech} if exists $params{contact_tech};
    my $response     = $api->rawCall( method => 'post', path => "/domain/zone/$zone_name/changeContact", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

1;
