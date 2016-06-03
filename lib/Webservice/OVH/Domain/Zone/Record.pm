package Webservice::OVH::Domain::Zone::Record;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

sub _new_existing {

    my ( $class, $api_wrapper, $zone, $record_id ) = @_;

    die "Missing record_id" unless $record_id;
    my $zone_name = $zone->name;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $record_id, _properties => $porperties, _zone => $zone }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub _new {

    my ( $class, $api_wrapper, $zone, %params ) = @_;

    my @keys_needed = qw{ field_type target };

    die "Missing zone" unless $zone;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $zone_name = $zone->name;
    my $body      = {};
    $body->{subDomain} = $params{sub_domain} if exists $params{sub_domain};
    $body->{target}    = $params{target};
    $body->{ttl}       = $params{ttl} if exists $params{ttl};
    $body->{fieldType} = $params{field_type} if exists $params{field_type};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/domain/zone/$zone_name/record", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $record_id  = $response->content->{id};
    my $properties = $response->content;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $record_id, _properties => $properties, _zone => $zone }, $class;

    return $self;
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $record_id = $self->id;
    carp "Record $record_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub zone {

    my ($self) = @_;

    return $self->{_zone};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->zone->name;
    my $record_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub field_type {

    my ($self) = @_;

    return $self->{_properties}->{fieldType};
}

sub sub_domain {

    my ($self) = @_;

    return $self->{_properties}->{subDomain};
}

sub target {

    my ($self) = @_;

    return $self->{_properties}->{target};
}

sub ttl {

    my ($self) = @_;

    return $self->{_properties}->{ttl};
}

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->{_zone}->name;
    my $record_id = $self->id;
    my $response  = $api->rawCall( method => 'delete', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

sub change {

    my ( $self, %params ) = @_;

    return unless $self->_is_valid;

    if ( scalar keys %params != 0 ) {

        my $api       = $self->{_api_wrapper};
        my $zone_name = $self->{_zone}->name;
        my $record_id = $self->id;
        my $body      = {};
        $body->{subDomain} = $params{sub_domain} if exists $params{sub_domain};
        $body->{target}    = $params{target}     if exists $params{target};
        $body->{ttl}       = $params{ttl}        if exists $params{ttl};
        my $response = $api->rawCall( method => 'put', path => "/domain/zone/$zone_name/record/$record_id", body => $body, noSignature => 0 );
        croak $response->error if $response->error;

        $self->properties;
    }
}

1;
