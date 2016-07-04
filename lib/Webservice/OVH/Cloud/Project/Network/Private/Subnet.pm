package Webservice::OVH::Cloud::Project::Network::Private::Subnet;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {

    my ( $class, %params ) = @_;

    die "Missing id"      unless $params{id};
    die "Missing project" unless $params{project};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing module"  unless $params{module};

    # Special Case, because subnet properties can't be called individually
    my $project_id = $params{project}->id;
    my $properties = $params{properties};
    my $api        = $params{wrapper};
    my $module     = $params{module};
    my $subnet_id  = $properties->{id};
    my $private    = $params{private};
    # No api check possible, because single subnets can't be checked
    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api, _id => $subnet_id, _properties => $properties, _project => $params{project}, _network => $private }, $class;

    return $self;
}

sub _new {

    my ( $class, %params ) = @_;

    my $project_id = $params{project}->id;
    my $api        = $params{wrapper};
    my $module     = $params{module};
    my $private    = $params{private};

    my @keys_needed = qw{ network project wrapper module dhcp end network no_gateway region start };
    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $network_id = $private->id;

    my $body = {};
    $body->{dhcp}       = $params{dhcp};
    $body->{end}        = $params{end};
    $body->{network}    = $params{network};
    $body->{no_gateway} = $params{no_gateway};
    $body->{region}     = $params{region};
    $body->{start}      = $params{start};

    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/network/private/$network_id/subnet", body => $body, noSignature => 0 );
    die $response->error if $response->error;

    my $subnet_id  = $response->content->{id};
    my $properties = $response->content;

    my $self = bless { _network => $params{network}, _module => $module, _valid => 1, _api_wrapper => $api, _id => $subnet_id, _properties => $properties, _project => $params{project} }, $class;

    return $self;
}

sub project {

    my ($self) = @_;

    return $self->{_project};
}

sub network {

    my ($self) = @_;

    return $self->{_network};
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    carp "Subnet is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {

    my ($self) = @_;

    return unless $self->_is_valid;

    return $self->{_id};
}

sub gateway_ip {

    my ($self) = @_;

    return unless $self->_is_valid;

    return $self->{_properties}->{gatewayIp};
}

sub cidr {

    my ($self) = @_;

    return unless $self->_is_valid;

    return $self->{_properties}->{cidr};
}

sub ip_pools {

    my ($self) = @_;

    return unless $self->_is_valid;

    return $self->{_properties}->{ipPools};
}

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $network_id = $self->network->id;
    my $subnet_id  = $self->id;

    my $response = $api->rawCall( method => 'delete', path => "/cloud/project/$project_id/network/private/$network_id/subnet/$subnet_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

1;
