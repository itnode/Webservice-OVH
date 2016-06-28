package Webservice::OVH::Cloud::Project::Network;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new {

    my ( $class, %params ) = @_;

    my $self = bless { _project => $params{project}, module => $params{module}, _api_wrapper => $params{wrapper}, _private => {}, _available_private => [] }, $class;

    return $self;
}

sub project {
    
    my ($self) = @_;
    
    return $self->{_project};
}


sub private_exists {

    my ( $self, $network_id, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api        = $self->{_api_wrapper};
        my $project_id = $self->project->id;
        my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/network/private/$network_id", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $network_id } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_available_private};

        return ( grep { $_ eq $network_id } @$list ) ? 1 : 0;
    }
}

sub privates {

    my ( $self, %filter ) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/network/private/", noSignature => 0 );
    croak $response->error if $response->error;

    my $private_array = $response->content;
    my $privates      = [];
    $self->{_available_private} = $private_array;

    foreach my $network_id (@$private_array) {

        if ( $self->private_exists( $network_id, 1 ) ) {
            my $private = $self->{_private}{$network_id} = $self->{_private}{$network_id} || Webservice::OVH::Cloud::Project::Network::Private->_new_existing( wrapper => $api, module => $self->{_module}, project => $self->project, id => $network_id );
            push @$privates, $private;
        }
    }

    return $privates;
}

sub private {

    my ( $self, $network_id ) = @_;

    if ( $self->private_exists($network_id) ) {

        my $api = $self->{_api_wrapper};
        my $private = $self->{_private}{$network_id} = $self->{_private}{$network_id} || Webservice::OVH::Cloud::Project::Network::Private->_new_existing( wrapper => $api, module => $self->{_module}, project => $self->project, id => $network_id );

        return $private;
    } else {

        carp "Network $network_id doesn't exists";
        return undef;
    }
}

1;