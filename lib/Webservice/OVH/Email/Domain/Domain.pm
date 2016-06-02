package Webservice::OVH::Email::Domain::Domain;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Email::Domain::Domain::Redirection;
use Webservice::OVH::Helper;

sub _new {

    my ( $class, $api_wrapper, $domain ) = @_;

    croak "Missing domain name" unless $domain;

    my $self = bless { _api_wrapper => $api_wrapper, _name => $domain, _service_infos => undef, _properties => undef, _redirections => {}, _accounts => {}, _mailing_lists => {} }, $class;

    return $self;
}

sub service_infos {

    my ($self) = @_;

    my $api                   = $self->{_api_wrapper};
    my $domain                = $self->name;
    my $response_service_info = $api->rawCall( method => 'get', path => "/email/domain/$domain/serviceInfos", noSignature => 0 );

    croak $response_service_info->error if $response_service_info->error;

    $self->{_service_infos} = $response_service_info->content;

    return $self->{_service_infos};
}

sub name {

    my ($self) = @_;

    return $self->{_name};
}

sub properties {

    my ($self) = @_;

    my $api                 = $self->{_api_wrapper};
    my $domain              = $self->name;
    my $response_properties = $api->rawCall( method => 'get', path => "/email/domain/$domain", noSignature => 0 );
    croak $response_properties->error if $response_properties->error;

    $self->{_properties} = $response_properties->content;

    return $self->{_properties};
}

sub allowed_account_size {

    my ($self) = @_;

    return $self->{_properties}->{allowedAccountSize};
}

sub creation_date {

    my ($self) = @_;

    my $str_datetime = $self->{_properties}->{creationDate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub filerz {

    my ($self) = @_;

    return $self->{_properties}->{filerz};
}

sub status {

    my ($self) = @_;

    return $self->{_properties}->{status};
}

sub redirections {

    my ( $self, %filter ) = @_;

    my $filter_from = ( exists $filter{from} && !$filter{from} ) ? "_empty_" : $filter{from};
    my $filter_to   = ( exists $filter{to}   && !$filter{to} )   ? "_empty_" : $filter{to};
    my $filter = Webservice::OVH::Helper->construct_filter( "from" => $filter_from, "to" => $filter_to );

    my $api         = $self->{_api_wrapper};
    my $domain_name = $self->name;
    my $response    = $api->rawCall( method => 'get', path => sprintf( "/email/domain/$domain_name/redirection%s", $filter ), noSignature => 0 );
    croak $response->error if $response->error;

    my $redirection_ids = $response->content;
    my $redirections    = [];

    foreach my $redirection_id (@$redirection_ids) {

        my $redirection = $self->{_redirections}{$redirection_id} = $self->{_redirections}{$redirection_id} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $redirection_id );
        push @$redirections, $redirection;
    }

    return $redirections;
}

sub redirection {

    my ( $self, $redirection_id ) = @_;

    croak "Missing redirection_id" unless $redirection_id;

    my $api = $self->{_api_wrapper};
    my $redirection = $self->{_redirections}{$redirection_id} = $self->{_redirections}{$redirection_id} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $redirection_id );

    return $redirection;
}

sub new_redirection {

    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $redirection = Webservice::OVH::Email::Domain::Domain::Redirection->_new( $api, $self, %params );

    return $redirection;
}

sub accounts {

    my ($self) = @_;

    my $api         = $self->{_api_wrapper};
    my $domain_name = $self->name;
    my $response    = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/account", noSignature => 0 );
    croak $response->error if $response->error;

    my $account_names = $response->content;
    my $accounts      = [];

    foreach my $account_name (@$account_names) {

        my $account = $self->{_accounts}{$account_name} = $self->{_accounts}{$account_name} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $account_name );
        push @$accounts, $account;
    }

    return $accounts;
}

sub account {

    my ( $self, $account_name ) = @_;

    croak "Missing account_name" unless $account_name;

    my $api = $self->{_api_wrapper};
    my $account = $self->{_accounts}{$account_name} = $self->{_accounts}{$account_name} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $account_name );

    return $account;
}

sub new_account {

    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $account = Webservice::OVH::Email::Domain::Domain::Account->_new( $api, $self, %params );

    return $account;
}

sub mailing_lists {

    my ($self) = @_;

    my $api         = $self->{_api_wrapper};
    my $domain_name = $self->name;
    my $response    = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/account", noSignature => 0 );
    croak $response->error if $response->error;

    my $mailing_list_names = $response->content;
    my $mailing_lists      = [];

    foreach my $mailing_list_name (@$mailing_list_names) {

        my $mailing_list = $self->{_mailing_lists}{$mailing_list_name} = $self->{_mailing_lists}{$mailing_list_name} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $mailing_list_name );
        push @$mailing_lists, $mailing_list;
    }

    return $mailing_lists;
}

sub mailing_list {

    my ( $self, $mailing_list_name ) = @_;

    croak "Missing mailing_list_name" unless $mailing_list_name;

    my $api = $self->{_api_wrapper};
    my $mailing_list = $self->{_mailing_lists}{$mailing_list_name} = $self->{_mailing_lists}{$mailing_list_name} || Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing( $api, $self, $mailing_list_name );

    return $mailing_list;
}

sub new_mailing_list {

    my ( $self, %params ) = @_;

    my $api = $self->{_api_wrapper};
    my $mailing_list = Webservice::OVH::Email::Domain::Domain::MailingList->_new( $api, $self, %params );

    return $mailing_list;
}

1;
