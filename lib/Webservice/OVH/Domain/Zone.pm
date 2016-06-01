package Webservice::OVH::Domain::Zone;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Helper;
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

sub dnssec_supported {
    
    my ($self) = @_;
    
    $self->properties unless $self->{_properties};
    
    return $self->{_properties}->{dnssecSupported} ? 1 : 0;
}

sub has_dns_anycast {
    
    my ($self) = @_;
    
    $self->properties unless $self->{_properties};
    
    return $self->{_properties}->{hasDnsAnycast} ? 1 : 0;
}

sub last_update {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    my $str_datetime = $self->{_properties}->{lastUpdate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub name_servers {
    
    my ($self) = @_;
    
    $self->properties unless $self->{_properties};
    
    return $self->{_properties}->{nameServers};
}

sub records {

    my ( $self, %filter ) = @_;

    my $filter_type      = (exists $filter{field_type} && !$filter{field_type}) ? "_empty_" : $filter{field_type};
    my $filter_subdomain = (exists $filter{subdomain} && !$filter{subdomain}) ? "_empty_" : $filter{subdomain};
    my $filter = Webservice::OVH::Helper->construct_filter( "fieldType" => $filter_type, "subDomain" => $filter_subdomain );

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $response  = $api->rawCall( method => 'get', path => sprintf("/domain/zone/$zone_name/record%s", $filter), noSignature => 0 );
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
    my $record = Webservice::OVH::Domain::Zone::Record->_new( $api, $self, %params );

    return $record;
}

sub name {

    my ($self) = @_;

    return $self->{_name};
}

sub change_contact {

    my ( $self, %params ) = @_;
    croak "at least one parameter needed: contact_billing contact_admin contact_tech" unless %params;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->name;
    my $body      = {};
    $body->{contactBilling} = $params{contact_billing} if exists $params{contact_billing};
    $body->{contactAdmin}   = $params{contact_admin}   if exists $params{contact_admin};
    $body->{contactTech}    = $params{contact_tech}    if exists $params{contact_tech};
    my $response = $api->rawCall( method => 'post', path => "/domain/zone/$zone_name/changeContact", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $tasks    = [];
    my $task_ids = $response->content;
    foreach my $task_id (@$task_ids) {

        my $task = $api->me->task_contact_change($task_id);
        push @$tasks, $task;
    }

    return $tasks;
}

1;
