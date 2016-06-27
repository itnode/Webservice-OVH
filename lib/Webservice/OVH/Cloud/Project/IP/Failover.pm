package Webservice::OVH::Cloud::Project::IP::Failover;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

=head2 _new

Internal Method to create the ip object.
This method is not ment to be called directly.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $project - root project

=item * Return: L<Webservice::OVH::Cloud::Project::IP::Failover>

=item * Synopsis: Webservice::OVH::Cloud::Project::IP::Failover->_new($ovh_api_wrapper, $project, $module);

=back

=cut

sub _new {

    my ( $class, $api_wrapper, $project, $failover_id, $module ) = @_;

    croak "Missing project" unless $project;

    my $self = bless { module => $module, _api_wrapper => $api_wrapper, _project => $project, _id => $failover_id, _properties => {} }, $class;

    $self->properties;

    return $self;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub project {

    my ($self) = @_;

    return $self->{_propject};
}

=head2 properties

Returns the raw properties as a hash. 
This is the original return value of the web-api. 

=over

=item * Return: HASH

=item * Synopsis: my $properties = $failover->properties;

=back

=cut

sub properties {

    my ($self) = @_;

    my $api         = $self->{_api_wrapper};
    my $failover_id = $self->id;
    my $project_id  = $self->project->id;
    my $response    = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/ip/failover/$failover_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub continent_code {

    my ($self) = @_;

    return $self->{_properties}->{continentCode};
}

sub progress {

    my ($self) = @_;

    return $self->{_properties}->{progress};
}

sub status {

    my ($self) = @_;

    return $self->{_properties}->{status};
}

sub ip {

    my ($self) = @_;

    return $self->{_properties}->{ip};
}

sub routed_to {

    my ($self) = @_;

    return $self->{_properties}->{routedTo};
}

sub sub_type {

    my ($self) = @_;

    return $self->{_properties}->{subType};
}

sub block {

    my ($self) = @_;

    return $self->{_properties}->{block};
}

sub geoloc {

    my ($self) = @_;

    return $self->{_properties}->{geoloc};
}

sub attach {

    my ( $self, $instance_id ) = @_;

    my $api         = $self->{_api_wrapper};
    my $failover_id = $self->id;
    my $project_id  = $self->project->id;

    croak "Missing instance_id" unless $instance_id;

    my $response = $api->rawCall( method => 'post', path => "/cloud/project/$project_id/ip/failover/$failover_id/attach", body => { instanceId => $instance_id }, noSignature => 0 );
    croak $response->error if $response->error;
}

1;
