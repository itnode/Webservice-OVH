package Webservice::OVH::Cloud::Project::Image;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {
    
    my ( $class, $api_wrapper, $module, $project, $image_id ) = @_;

    die "Missing image_id" unless $image_id;
    my $project_id = $project->id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/cloud/project/$project_id/image/$image_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $image_id, _properties => $porperties, _project => $project }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub id {
    
    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $image_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/image/$image_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub visibility {
    
    my ($self) = @_;

    return $self->{_properties}->{visibility};
}

sub status {
    
    my ($self) = @_;

    return $self->{_properties}->{status};
}

sub name {
    
    my ($self) = @_;

    return $self->{_properties}->{name};
}

sub region {
    
    my ($self) = @_;

    return $self->{_properties}->{region};
}

sub min_disk {
    
    my ($self) = @_;

    return $self->{_properties}->{minDisk};
}

sub size {
    
    my ($self) = @_;

    return $self->{_properties}->{size};
}

sub creation_date {
    
    my ($self) = @_;

    return unless $self->_is_valid;
    
    my $str_datetime = $self->{_properties}->{creationDate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub min_ram {
    
    my ($self) = @_;

    return $self->{_properties}->{minRam};
}

sub user {
    
    my ($self) = @_;

    return $self->{_properties}->{user};
}

sub type {
    
    my ($self) = @_;

    return $self->{_properties}->{type};
}



1;
