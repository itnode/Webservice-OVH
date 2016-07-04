package Webservice::OVH::Cloud::Project::Instance;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

##############

sub _new_empty {
    
    my ( $class, $api_wrapper, $project, $module ) = @_;
    
    my $self = bless { _module => $module, _valid => 0, _api_wrapper => $api_wrapper, _project => $project, _available_groups => [], _groups => {} }, $class;
}

sub group_exists {
    
    my ( $self, $group_id, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api        = $self->{_api_wrapper};
        my $project_id = $self->project->id;
        my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/group", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $group_id } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_available_groups};

        return ( grep { $_ eq $group_id } @$list ) ? 1 : 0;
    }
}

sub groups {
    
    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $project_id = $self->{_project}->id;
    my $response = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/group", noSignature => 0 );
    croak $response->error if $response->error;

    my $group_array = $response->content;
    my $groups      = [];
    $self->{_available_groups} = $group_array;

    foreach my $group_id (@$group_array) {
        if ( $self->group_exists( $group_id, 1 ) ) {
            my $group = $self->{_groups}{$group_id} = $self->{_groups}{$group_id} || Webservice::OVH::Cloud::Project::Instance::Group->_new_existing( $api, $self->{_module}, $self->project, $group_id );
            push @$groups, $group;
        }
    }

    return $groups;
}

sub group {
    
    my ( $self, $group_id ) = @_;

    if ( $self->group_exists($group_id) ) {

        my $api = $self->{_api_wrapper};
        my $instance = $self->{_group}{$group_id} = $self->{_group}{$group_id} || Webservice::OVH::Cloud::Project::Instance->_new_existing( $api, $self->{_module}, $self->project, $group_id );

        return $instance;
    } else {

        carp "Instance $group_id doesn't exists";
        return undef;
    }
}

sub create_group {
    
    my ( $self, %params ) = @_;
    
    my $api = $self->{_api_wrapper};
    my $group = Webservice::OVH::Cloud::Project::Instance::Group->_new( $api, $self->{_module}, $self->project, %params );
}


##############

sub _new_existing {

    my ( $class, %params ) = @_;

    die "Missing id" unless $params{id};
    die "Missing module" unless $params{module};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing project" unless $params{project};
    
    my $instance_id = $params{id};
    my $module = $params{module};
    my $api_wrapper = $params{wrapper};
    my $project = $params{project};
    my $project_id = $project->id;
    
    my $response = $api_wrapper->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/$instance_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $instance_id, _properties => $porperties, _project => $project }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub _new {

    my ( $class, %params ) = @_;
    
    die "Missing module" unless $params{module};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing project" unless $params{project};

    my @keys = qw{ flavor_id image_id name region };
    if ( my @missing_parameters = grep { not $params{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }
    
    my $module = $params{module};
    my $api_wrapper = $params{wrapper};
    my $project = $params{project};
    my $project_id = $project->id;

    my $body      = {};
    $body->{flavorId} = $params{flavor_id};
    $body->{imageId} = $params{image_id};
    $body->{name} = $params{name};
    $body->{region} = $params{region};
    $body->{groupId} = $params{group_id} if exists $params{group_id};
    $body->{monthlyBilling} = $params{monthly_billing} if exists $params{monthly_billing};
    $body->{sshKeyId} = $params{ssh_key_id} if exists $params{ssh_key_id};
    $body->{userData} = $params{user_data} if exists $params{user_data};
    
    my $networks = $params{networks};
    
    foreach my $network (@$networks) {
        
        push @{$body->{networks}}, { ip => $network->{ip}, networkId => $network->{network_id} };
    }
    
    my $response   = $api_wrapper->rawCall( method => 'post', path => "/cloud/project/$project_id/instance", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $instance_id  = $response->content->{id};
    my $properties = $response->content;

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $instance_id, _properties => $properties, _project => $project }, $class;

    return $self;
}

sub id {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_id};
}


sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}


sub _is_valid {

    my ($self) = @_;

    carp "Instance is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub project {
    
    my ($self) = @_;

    return $self->{_project};
}

sub properties {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api      = $self->{_api_wrapper};
    my $id       = $self->id;
    my $project_id = $self->project->id;
    my $response = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/group/$id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub description {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{description};
}

sub status {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{status};
}

sub name {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{name};
}

sub region {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{region};
}

sub image {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{image};
}

sub created {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $str_datetime = $self->{_properties}->{created};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub ssh_key {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{sshKey};
}

sub monthly_billing {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{monthlyBilling};
}

sub ip_addresses {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{ipAddresses};
}

sub flavor {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;

    return $self->{_properties}->{flavor};
}

sub change {
    
    my ($self, $instance_name) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing instance_name" unless $instance_name;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'put', path => "/cloud/project/$project_id/instance/$instance_id", body => { instanceName => $instance_name }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub delete {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'delete', path => "/cloud/project/$project_id/instance/$instance_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_valid} = 0;
}

sub active_monthly_billing {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/activeMonthlyBilling", body => {}, noSignature => 0 );
    croak $response->error if $response->error;
}

sub monitoring {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/$instance_id/monitoring", noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}

sub reboot {
    
    my ($self, $type) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing or wrong reboot type: hard, soft" unless $type && ($type eq 'hard' || $type eq 'soft');
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/reboot", body => {type => $type}, noSignature => 0 );
    croak $response->error if $response->error;
}

sub reinstall {
    
    my ($self, $image) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing image" unless $image;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    my $image_id = $image->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/reinstall", body => { imageId => $image_id }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub rescue_mode {
    
    my ($self, $rescue, $image) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing image" unless $rescue;
    
    my $rescue_mode = $rescue ne 'false' ? 'true' : 'false';
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    my $image_id = $image->id if $image;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/reinstall", body => { imageId => $image_id, rescue => $rescue_mode }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub resize {
    
    my ($self, $snapshot_name) = @_;
    
    return unless $self->_is_valid;
    
    croak "Missing snapshot_name" unless $snapshot_name;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/snapshot", body => { snapshotName => $snapshot_name }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub vnc {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $instance_id = $self->id;
    
    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/$instance_id/vnc", body => { }, noSignature => 0 );
    croak $response->error if $response->error;
    
    return $response->content;
}



1;