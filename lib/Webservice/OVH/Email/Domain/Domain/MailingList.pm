package Webservice::OVH::Email::Domain::Domain::MailingList;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Helper;

sub _new_existing {

    my ( $class, $api_wrapper, $domain, $mailing_list_name ) = @_;

    die "Missing mailing_list_name" unless $mailing_list_name;
    my $domain_name = $domain->name;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/email/domain/$domain_name/mailingList/$mailing_list_name", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;
    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _name => $mailing_list_name, _properties => $porperties, _domain => $domain }, $class;

    return $self;
}

sub _new {

    my ( $class, $api_wrapper, $domain, %params ) = @_;

    my @keys_needed = qw{ language name options owner_email };

    die "Missing domain" unless $domain;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $domain_name = $domain->name;
    my $body        = {};
    $body->{language}   = $params{language};
    $body->{name}       = $params{name};
    $body->{options}    = $params{options};
    $body->{ownerEmail} = $params{owner_email};
    $body->{replyTo}    = $params{reply_to} if exists $params{reply_to};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/email/domain/$domain_name/account", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $properties = $response->properties;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $properties->{id}, _name => $params{name}, _properties => $properties, _domain => $domain }, $class;

    return $self;
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $mailing_list_name = $self->name;
    carp "Mailinglist $mailing_list_name is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub name {

    my ($self) = @_;

    return $self->{_name};
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/mailingList/$mailing_list_name", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub language {

    my ($self) = @_;

    return $self->{_properties}->{language};
}

sub options {

    my ($self) = @_;

    return $self->{_properties}->{options};
}

sub owner_email {

    my ($self) = @_;

    return $self->{_properties}->{ownerEmail};
}

sub reply_to {

    my ($self) = @_;

    return $self->{_properties}->{replyTo};
}

sub nb_subscribers_update_date {

    my ($self) = @_;

    my $str_datetime = $self->{_properties}->{nbSubscribersUpdateDate};
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);

    return $datetime;
}

sub nb_subscribers {

    my ($self) = @_;

    return $self->{_properties}->{nbSubscribers};
}

sub change {

    my ( $self, %params ) = @_;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $body              = {};
    $body->{language}   = $params{language};
    $body->{ownerEmail} = $params{owner_email};
    $body->{replyTo}    = $params{reply_to};
    my $response = $api->rawCall( method => 'put', path => "/email/domain/$domain_name/mailingList/$mailing_list_name", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

sub delete {

    my ($self) = @_;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/mailingList/$mailing_list_name", noSignature => 0 );
    croak $response->error if $response->error;
}

sub change_options {

    my ( $self, %params ) = @_;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $body              = {};
    $body->{moderatorMessage}     = $params{moderator_message};
    $body->{subscribeByModerator} = $params{subscribe_by_moderator};
    $body->{usersPostOnly}        = $params{users_post_only};
    my $response = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/changeOptions", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

sub moderators {

    my ($self) = @_;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/moderator", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub moderator {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/moderator/$email", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_moderator {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $body              = { email => $email };
    my $response          = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/moderator", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

sub delete_moderator {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/moderator/$email", noSignature => 0 );
    croak $response->error if $response->error;
}

sub send_list_by_email {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $body              = { email => $email };
    my $response          = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/sendListByEmail", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

sub subscribers {

    my ( $self, $email ) = @_;

    my $filter_email = $email ? $email : "";
    my $filter = Webservice::OVH::Helper->construct_filter( "email" => $filter_email );

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;

    my $response = $api->rawCall( method => 'get', path => sprintf( "/email/domain/$domain_name/mailingList/$mailing_list_name/subscriber%s", $filter ), noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub subscriber {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;

    my $response = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/subscriber/$email", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_subscriber {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $body              = { email => $email };
    my $response          = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/subscriber", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

sub delete_subscriber {

    my ( $self, $email ) = @_;

    croak "Missing email" unless $email;

    my $api               = $self->{_api_wrapper};
    my $domain_name       = $self->domain->name;
    my $mailing_list_name = $self->name;
    my $response          = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/mailingList/$mailing_list_name/subscriber/$email", noSignature => 0 );
    croak $response->error if $response->error;
}

1;
