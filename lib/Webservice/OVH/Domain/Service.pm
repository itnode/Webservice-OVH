package Webservice::OVH::Domain::Service;

use strict;
use warnings;
use Carp qw{ carp croak };
use DateTime;

our $VERSION = 0.1;

use Webservice::OVH::Helper;

use Webservice::OVH::Me::Contact;

sub _new {

    my ( $class, $api_wrapper, $service_name ) = @_;

    croak "Missing service_name" unless $service_name;

    my $self = bless { _api_wrapper => $api_wrapper, _name => $service_name, _owner => undef, _service_info => undef, _properties => undef }, $class;

    return $self;
}

sub name {

    my ($self) = @_;

    return $self->{_name};
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

sub dnssec_supported {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{dnssecSupported} ? 1 : 0;
}

sub domain {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{domain};
}

sub glue_record_ipv6_supported {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{glueRecordIpv6Supported} ? 1 : 0;
}

sub glue_record_multi_ip_supported {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{glueRecordMultiIpSupported} ? 1 : 0;
}

sub last_update {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    my $str_datetime = $self->{_properties}->{lastUpdate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub name_server_type {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{nameServerType};
}

sub offer {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{offer};
}

sub owo_supported {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{owoSupported} ? 1 : 0;
}

sub parent_service {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{parentService};
}

sub transfer_lock_status {

    my ($self) = @_;

    $self->properties unless $self->{_properties};

    return $self->{_properties}->{transferLockStatus};
}

sub whois_owner {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $properties = $self->{_properties} || $self->properties;
    my $owner_id   = $properties->{whoisOwner};
    my $owner      = $self->{_owner} = $self->{_owner} || Webservice::OVH::Me::Contact->_new_existing( $api, $owner_id );

    return $self->{_owner};
}

sub change_contact {

    my ( $self, %params ) = @_;

    croak "at least one parameter needed: contact_billing contact_admin contact_tech" unless %params;

    my $api          = $self->{_api_wrapper};
    my $service_name = $self->name;
    my $body         = {};
    $body->{contactBilling} = $params{contact_billing} if exists $params{contact_billing};
    $body->{contactAdmin}   = $params{contact_admin}   if exists $params{contact_admin};
    $body->{contactTech}    = $params{contact_tech}    if exists $params{contact_tech};
    my $response = $api->rawCall( method => 'post', path => "/domain/$service_name/changeContact", body => $body, noSignature => 0 );

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
