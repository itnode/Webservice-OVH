package Webservice::OVH::Hosting::Web;

=encoding utf-8

=head1 NAME

Webservice::OVH::Hosting::Web

=head1 SYNOPSIS

=head1 DESCRIPTION

Gives access to services and zones connected to the uses account.

=head1 METHODS

=cut

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.44;

use Webservice::OVH::Hosting::Web::Service;

=head2 _new

Internal Method to create the Web object.
This method is not ment to be called external.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object

=item * Return: L<Webservice::OVH::Order>

=item * Synopsis: Webservice::OVH::Order->_new($ovh_api_wrapper, $self);

=back

=cut

sub _new {

    my ( $class, %params ) = @_;

    die "Missing module"  unless $params{module};
    die "Missing wrapper" unless $params{wrapper};

    my $module      = $params{module};
    my $api_wrapper = $params{wrapper};

    my $self = bless { _module => $module, _api_wrapper => $api_wrapper, _services => {}, _aviable_services => [], }, $class;

    return $self;
}

=head2 service_exists

Returns 1 if service is available for the connected account, 0 if not.

=over

=item * Parameter: $service_name - service name, $no_recheck - (optional)only for internal usage 

=item * Return: VALUE

=item * Synopsis: print "mydomain.com exists" if $ovh->hosting->web->service_exists("mydomain.com");

=back

=cut

sub service_exists {

    my ( $self, $service_name, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api = $self->{_api_wrapper};
        my $response = $api->rawCall( method => 'get', path => "/hosting/web", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $service_name } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_aviable_services};

        return ( grep { $_ eq $service_name } @$list ) ? 1 : 0;
    }
}

=head2 services

Produces an array of all available services that are connected to the used account.

=over

=item * Return: ARRAY

=item * Synopsis: my $services = $ovh->order->services();

=back

=cut

sub services {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/hosting/web", noSignature => 0 );
    croak $response->error if $response->error;

    my $service_array = $response->content;
    my $services      = [];
    $self->{_aviable_services} = $service_array;

    foreach my $service_name (@$service_array) {
        if ( $self->service_exists( $service_name, 1 ) ) {
            my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Hosting::Web::Service->_new( wrapper => $api, id => $service_name, module => $self->{_module} );
            push @$services, $service;
        }
    }

    return $services;
}

=head2 service

Returns a single service by name

=over

=item * Parameter: $service_name - service name

=item * Return: L<Webservice::OVH::Hosting::Web::Service>

=item * Synopsis: my $service = $ovh->hosting->web->service("mydomain.com");

=back

=cut

sub service {

    my ( $self, $service_name ) = @_;

    if ( $self->service_exists($service_name) ) {

        my $api = $self->{_api_wrapper};
        my $service = $self->{_services}{$service_name} = $self->{_services}{$service_name} || Webservice::OVH::Hosting::Web::Service->_new( wrapper => $api, id => $service_name, module => $self->{_module} );

        return $service;
    } else {

        carp "Service $service_name doesn't exists";
        return undef;
    }
}

1;