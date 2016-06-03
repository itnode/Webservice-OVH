package Webservice::OVH::Email::Domain::Domain::Account;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {

    my ( $class, $api_wrapper, $domain, $account_name ) = @_;
    die "Missing account_name" unless $account_name;
    $account_name = lc $account_name;

    my $domain_name = $domain->name;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/email/domain/$domain_name/account/$account_name", noSignature => 0 );
    croak $response->error if $response->error;

    my $porperties = $response->content;
    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _name => $account_name, _properties => $porperties, _domain => $domain }, $class;

    return $self;
}

sub _new {

    my ( $class, $api_wrapper, $domain, %params ) = @_;

    my @keys_needed = qw{ account_name password };

    die "Missing domain" unless $domain;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $domain_name = $domain->name;
    my $body        = {};
    $body->{accountName} = $params{account_name};
    $body->{password}    = $params{password};
    $body->{description} = $params{description} if exists $params{description};
    $body->{size}        = $params{size} if exists $params{size};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/email/domain/$domain_name/account", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $properties = $response->content;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _name => $params{account_name}, _properties => $properties, _domain => $domain }, $class;

    return $self;

}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $account_name = $self->name;
    carp "Account $account_name is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub name {

    my ($self) = @_;

    return $self->{_name};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api          = $self->{_api_wrapper};
    my $domain_name  = $self->domain->name;
    my $account_name = $self->name;
    my $response     = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/account/$account_name", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};

}

sub is_blocked {

    my ($self) = @_;

    return $self->{_properties}->{isBlocked} ? 1 : 0;

}

sub email {

    my ($self) = @_;

    return $self->{_properties}->{email};

}

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

sub description {

    my ($self) = @_;

    return $self->{_properties}->{description};
}

sub size {

    my ($self) = @_;

    return $self->{_properties}->{size};
}

sub change {

    my ( $self, %params ) = @_;

    my $api          = $self->{_api_wrapper};
    my $domain_name  = $self->domain->name;
    my $account_name = $self->name;
    my $body         = {};
    $body->{description} = $params{description} if exists $params{description};
    $body->{size}        = $params{size}        if exists $params{size};
    my $response = $api->rawCall( method => 'put', path => "/email/domain/$domain_name/account/$account_name", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

}

sub delete {

    my ( $self, %params ) = @_;

    my $api          = $self->{_api_wrapper};
    my $domain_name  = $self->domain->name;
    my $account_name = $self->name;
    my $response     = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/account/$account_name", noSignature => 0 );
    croak $response->error if $response->error;

}

sub change_password {

    my ( $self, $password ) = @_;

    return "Password too long"  if length $password > 30;
    return "Password too short" if length $password < 9;
    return "No '´' allowed"    if index( $password, '´' );

    my $api          = $self->{_api_wrapper};
    my $domain_name  = $self->domain->name;
    my $account_name = $self->name;
    my $body         = { password => $password };
    my $response     = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/account/$account_name/changePassword", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

}

sub usage {

    my ($self) = @_;

    my $api          = $self->{_api_wrapper};
    my $domain_name  = $self->domain->name;
    my $account_name = $self->name;
    my $response     = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/account/$account_name/usage", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;

}

1;
