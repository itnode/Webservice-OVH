package Webservice::OVH::Email::Domain::Domain::Redirection;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {

    my ( $class, $api_wrapper, $domain, $redirection_id ) = @_;

    die "Missing redirection_id" unless $redirection_id;
    my $domain_name = $domain->name;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $redirection_id, _properties => $porperties, _domain => $domain }, $class;

    return $self;
}

sub _new {

    my ( $class, $api_wrapper, $domain, %params ) = @_;

    my @keys_needed = qw{ from target local_copy to };

    die "Missing domain" unless $domain;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $domain_name = $domain->name;
    my $body        = {};
    $body->{from}      = $params{from};
    $body->{to}        = $params{to};
    $body->{localCopy} = $params{local_copy};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/email/domain/$domain_name/redirection/", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $redirection_id = $response->content->{id};
    my $properties     = $response->content;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $redirection_id, _properties => $properties, _domain => $domain }, $class;

    return $self;
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $redirection_id = $self->id;
    carp "Redirection $redirection_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api            = $self->{_api_wrapper};
    my $domain_name    = $self->domain->name;
    my $redirection_id = $self->id;
    my $response       = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api            = $self->{_api_wrapper};
    my $domain_name    = $self->{_domain}->name;
    my $redirection_id = $self->id;
    my $response       = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

sub change {

    my ( $self, $to ) = @_;

    return unless $self->_is_valid;

    croak "Missing to as parameter" unless $to;

    my $api       = $self->{_api_wrapper};
    my $domain_name = $self->{_zone}->name;
    my $redirection_id = $self->id;
    my $body      = {};
    $body->{to} = $to;
    my $response = $api->rawCall( method => 'post', path => " /email/domain/$domain_name/redirection/$redirection_id/changeRedirection", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

1;
