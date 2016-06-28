package Webservice::OVH::Cloud::Project::SSHKey;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {
    
    my ( $class, $api_wrapper, $module, $project, $key_id ) = @_;

    die "Missing key_id" unless $key_id;
    my $project_id = $project->id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/cloud/project/$project_id/sshkey/$key_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $key_id, _properties => $porperties, _project => $project }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub _new {
    
    my ( $class, $api_wrapper, $module, $project, %params ) = @_;

    die "Missing project" unless $project;
    
    my @keys_needed = qw{ public_key region };
    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $project_id = $project->id;
    my $body      = {};
    $body->{name} = $params{name};
    $body->{publicKey} = $params{public_key};
    $body->{region} = $params{region} if exists $params{region};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/cloud/project/{serviceName}/sshkey", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $key_id  = $response->content->{properties}->{id};
    my $properties = $response->content;

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $key_id, _properties => $properties, _project => $project }, $class;

    return $self;
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $key_id = $self->id;
    carp "Key $key_id is not valid anymore" unless $self->is_valid;
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
    my $key_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/sshkey/$key_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub finger_print {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{fingerPrint};
}

sub regions {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{regions};
}

sub name {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{name};
}

sub public_key {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{publicKey};
}

sub delete {
    
     my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project_id;
    my $key_id = $self->id;
    
    my $response = $api->rawCall( method => 'delete', path => "/cloud/project/$project_id/instance/group/$key_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_valid} = 0;
}

1;
