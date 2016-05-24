package Webservice::OVH::Domain::Service;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {

    my ( $class, $api_wrapper, $type, $task_id ) = @_;

    die "Missing contact_id" unless $task_id;
    die "Missing type"       unless $type;

    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/task/contactChange/$task_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;
    my $self = bless { _api_wrapper => $api_wrapper, _id => $task_id, _type => $type, _properties => $porperties }, $class;

    return $self;
}

sub type {

    my ($self) = @_;

    return $self->{_type};
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    my $task_id  = $self->id;
    my $api      = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/task/contactChange/$task_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_properties} = $response->content;

    return $self->{_properties};
}

sub accept {

    my ( $self, $token ) = @_;

    croak "Missing Token" unless $token;

    my $task_id  = $self->id;
    my $api      = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'post', path => "/me/task/contactChange/$task_id/accept", body => { token => $token }, noSignature => 0 );
    croak $response->error if $response->error;
}

sub refuse {

    my ( $self, $token ) = @_;

    croak "Missing Token" unless $token;

    my $task_id  = $self->id;
    my $api      = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'post', path => "/me/task/contactChange/$task_id/refuse", body => { token => $token }, noSignature => 0 );
    croak $response->error if $response->error;

}

sub resend_email {

    my ($self) = @_;

    my $task_id  = $self->id;
    my $api      = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'post', path => "/me/task/contactChange/$task_id/resendEmail", body => {}, noSignature => 0 );
    croak $response->error if $response->error;

}

1;
