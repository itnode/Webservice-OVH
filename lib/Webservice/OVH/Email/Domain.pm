package Webservice::OVH::Email::Domain;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Email::Domain::Domain;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _domains => {}, _aviable_domains => [] }, $class;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/email/domain/", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_aviable_domains} = $response->content;

    return $self;
}

sub domain_exists {

    my ( $self, $domain, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api = $self->{_api_wrapper};
        my $response = $api->rawCall( method => 'get', path => "/email/domain/", noSignature => 0 );
        croak $response->error if $response->error;

        $self->{_aviable_domains} = $response->content;

        my $list = $response->content;

        return ( grep { $_ eq $domain } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_aviable_domains};

        return ( grep { $_ eq $domain } @$list ) ? 1 : 0;
    }
}

sub domains {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/email/domain/", noSignature => 0 );
    croak $response->error if $response->error;

    my $domain_array = $response->content;
    my $domains      = [];
    $self->{_aviable_domains} = $domain_array;

    foreach my $domain (@$domain_array) {
        if ( $self->domain_exists( $domain, 1 ) ) {
            my $domain = $self->{_domains}{$domain} = $self->{_domains}{$domain} || Webservice::OVH::Email::Domain::Domain->_new( $api, $domain );
            push @$domains, $domain;
        }
    }

    return $domains;

}

sub domain {

    my ( $self, $domain ) = @_;

    if ( $self->domain_exists($domain) ) {

        my $api = $self->{_api_wrapper};
        my $domain = $self->{_domains}{$domain} = $self->{_domains}{$domain} || Webservice::OVH::Email::Domain::Domain->_new( $api, $domain );

        return $domain;
    } else {

        carp "Domain $domain doesn't exists";
        return undef;
    }
}

1;
