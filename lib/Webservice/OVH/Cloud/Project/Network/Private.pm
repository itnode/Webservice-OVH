package Webservice::OVH::Cloud::Project::Network::Private;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {
    
    my ( $class, %params ) = @_;

    die "Missing id" unless $params{id};
    die "Missing project" unless $params{project};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing module" unless $params{module};
    
    my $project_id = $params{project}->id;
    my $network_id = $params{id};
    my $api = $params{wrapper};
    my $module = $params{module};
    my $response = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/network/private/$network_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _available_subnets => [], _subnets => {}, _module => $module, _valid => 1, _api_wrapper => $api, _id => $network_id, _properties => $porperties, _project => $params{project} }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub _new {
    
    my ( $class, %params ) = @_;
    
    my $project_id = $params{project}->id;
    my $api = $params{wrapper};
    my $module = $params{module};

    my @keys_needed = qw{ project wrapper module vlan_id name };
    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $body      = { };
    $body->{vlanId} = $params{vlanId};
    $body->{name} = $params{name};
    $body->{regions} = $params{region} if exists $params{region};
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/network/private", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $network_id  = $response->content->{id};
    my $properties = $response->content;

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api, _id => $network_id, _properties => $properties, _project => $params{project} }, $class;

    return $self;
}

sub project {
    
    my ($self) = @_;

    return $self->{_project};
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $network_id = $self->id;
    carp "Network $network_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $network_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/network/private/$network_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub regions {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{regions};
}

sub status {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{status};
}

sub name {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{name};
}

sub type {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{type};
}

sub vlan_id {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{vlanId};
}

sub change {
    
    my ($self, $name) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing name" unless $name;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $network_id = $self->id;
    
    my $response = $api->rawCall( method => 'put', path => "/cloud/project/$project_id/network/private/$network_id", body => { name => $name }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub delete {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $network_id = $self->id;
    
    my $response = $api->rawCall( method => 'delete', path => "/cloud/project/$project_id/network/private/$network_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_valid} = 0;
}

sub region {
    
    my ($self, $region) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing region" unless $region;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $network_id = $self->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/network/private/$network_id/region", body => { region => $region }, noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub subnets {
    
    my ( $self ) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $network_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/network/private/$network_id/subnet", noSignature => 0 );
    croak $response->error if $response->error;

    my $subnet_array = $response->content;
    my $subnets      = [];
    $self->{_available_subnets} = $subnet_array;

    foreach my $subnet (@$subnet_array) {
        
        my $subnet_id = $subnet->{id};
        my $subnet = $self->{_subnets}{$subnet_id} = $self->{_subnets}{$subnet_id} || Webservice::OVH::Cloud::Project::Network::Private::Subnet->_new_existing( wrapper => $api, module => $self->{_module}, project => $self->project, id => $subnet_id, network => $self );
        push @$subnets, $subnet;
    }

    return $subnets;
}

sub subnet {
    
    my ( $self, $subnet_id ) = @_;
    
    my $subnets = $self->subnets;
    
    my @subnet_search = grep { $_->id eq $subnet_id } @$subnet_id;
    
    return scalar @subnet_search > 0 ? $subnet_search[0] : undef;
}

sub create_subnet {
    
    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $instance = Webservice::OVH::Cloud::Project::Instance->_new( wrapper => $api, module => $self->{_module}, network => $self, %params );
}



1;