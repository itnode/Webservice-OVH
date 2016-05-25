package Webservice::OVH;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use OvhApi;
use Webservice::OVH::Domain;
use Webservice::OVH::Me;
use Webservice::OVH::Order;

use JSON;
use File::Slurp qw(read_file);

# Class variables

# End - Class variables

sub new_from_json {

    my ( $class, $file_json ) = @_;
    
    my $json = read_file $file_json, {binmode => ':utf8'};
    
    my $Json = JSON->new->allow_nonref;
    my $data = $Json->decode( $json );
    
    my @keys = qw{ application_key application_secret consumer_key };

    if ( my @missing_parameters = grep { not $data->{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }
    
    my $api_wrapper = OvhApi->new( 'type' => "https://eu.api.ovh.com/1.0", applicationKey => $data->{application_key}, applicationSecret => $data->{application_secret}, consumerKey => $data->{consumer_key} );
    my $domain      = Webservice::OVH::Domain->_new($api_wrapper);
    my $me          = Webservice::OVH::Me->_new($api_wrapper);
    my $order       = Webservice::OVH::Order->_new($api_wrapper);
    
    OvhApi->setRequestTimeout( timeout => $data->{timeout} || 120 );

    my $self = bless { _api_wrapper => $api_wrapper }, $class;
    
    return $self;
}

sub new {

    my ( $class, %params ) = @_;

    my @keys = qw{ application_key application_secret consumer_key };

    if ( my @missing_parameters = grep { not $params{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $api_wrapper = OvhApi->new( 'type' => "https://eu.api.ovh.com/1.0", applicationKey => $params{application_key}, applicationSecret => $params{application_secret}, consumerKey => $params{consumer_key} );
    my $domain      = Webservice::OVH::Domain->_new($api_wrapper);
    my $me          = Webservice::OVH::Me->_new($api_wrapper);
    my $order       = Webservice::OVH::Order->_new($api_wrapper);

    OvhApi->setRequestTimeout( timeout => $params{timeout} || 120 );

    my $self = bless { _api_wrapper => $api_wrapper }, $class;

    $self->{_domain}      = $domain;
    $self->{_me}          = $me;
    $self->{_order}       = $order;
    $self->{_api_wrapper} = $api_wrapper;

    return $self;
}

sub set_timeout {

    my ( $class, $timeout ) = @_;

    OvhApi->setRequestTimeout( timeout => $timeout );
}

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

sub me {

    my ($self) = @_;

    return $self->{_me};
}

sub order {

    my ($self) = @_;

    return $self->{_order};
}

sub new_account {

    my ( $self, $email, $firstname, $birthday ) = @_;

    my $body = { birthday => $birthday, firstname => $firstname, country => 'DE', email => $email, legalform => 'individual', ovhCompany => 'ovh', ovhSubsidiary => 'DE' };

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'post', path => "/newAccount", noSignature => 0 );
    croak $response->error if $response->error;
}

1;
