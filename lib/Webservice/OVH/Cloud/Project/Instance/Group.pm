package Webservice::OVH::Cloud::Project::Instance::Group;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {
    
    my ( $class, %params ) = @_;
    
    die "Missing module"  unless $params{module};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing id"      unless $params{id};
    die "Missing project"      unless $params{project};

    my $group_id  = $params{id};
    my $api_wrapper = $params{wrapper};
    my $module      = $params{module};
    my $project = $params{project};
    my $project_id = $project->id;

    my $response = $api_wrapper->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/group/$group_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $group_id, _properties => $porperties, _project => $project }, $class;

        return $self;
    } else {

        return undef;
    }
}

sub _new {
    
    my ( $class, %params ) = @_;

    die "Missing module"  unless $params{module};
    die "Missing wrapper" unless $params{wrapper};
    die "Missing project"      unless $params{project};

    my $api_wrapper = $params{wrapper};
    my $module      = $params{module};
    my $project = $params{project};
    my $project_id = $project->id;
    
    my @keys_needed = qw{ region name };
    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $body      = { region => $params{region}, name => $params{name} };
    my $response = $api_wrapper->rawCall( method => 'post', path => "/cloud/project/$project_id/instance/group", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $group_id  = $response->content->{id};
    my $properties = $response->content;

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $group_id, _properties => $properties, _project => $project }, $class;

    return $self;
}

=head2 project

Root Project.

=over

=item * Return: L<Webservice::OVH::Cloud::Project>

=item * Synopsis: my $project = $group->project;

=back

=cut

sub project {

    my ($self) = @_;

    return $self->{_project};
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    carp "Group is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $group_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance/group/$group_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub name {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{name};
}

sub region {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{region};
}

sub instance_ids {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{instance_ids};
}

sub affinity {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    return $self->{_properties}->{Affinity};
}

sub delete {
    
    my ($self) = @_;
    
    return unless $self->_is_valid;
    
    my $api = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $group_id = $self->id;
    
    my $response = $api->rawCall( method => 'delete', path => "/cloud/project/$project_id/instance/group/$group_id", noSignature => 0 );
    croak $response->error if $response->error;
    
    $self->{_valid} = 0;
}

1;