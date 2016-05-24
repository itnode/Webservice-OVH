package Webservice::OVH::Domain::Zone;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Domain::Zone::Record;

sub new {

    my ( $class, $api_wrapper, $zone_name ) = @_;

    croak "Missing zone_name" unless $zone_name;

    my $self = bless { _api_wrapper => $api_wrapper, _name => $zone_name, _service_info => undef, _properties => undef, _records = {} }, $class;

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
    
    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/domain/zone/record", noSignature => 0 );
    croak $response->error if $response->error;
    
    my $record_ids = $response->content;
    my $records = [];
    
    foreach my $record_id (@$record_ids) {

        my $record = $self->{_records}{$record_id} = $self->{_records}{$record_id} || Webservice::OVH::Domain::Zone::Record->new( $api, $record_id );
        push @$records, $record;
    }

    return $records;
}

sub new_record {

    my ( $self, %params ) = @_;

    return undef;
}

1;
