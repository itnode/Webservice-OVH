package Webservice::OVH::Cloud::Project;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Cloud::Project::IP;

=head2 _new

Internal Method to create the project object.
This method is not ment to be called directly.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $id - api id

=item * Return: L<Webservice::OVH::Cloud::Project>

=item * Synopsis: Webservice::OVH::Cloud::Project->_new($ovh_api_wrapper, $project_name, $module);

=back

=cut

sub _new {

    my ( $class, $api_wrapper, $project_id, $module ) = @_;

    croak "Missing project_id" unless $project_id;

    my $self = bless { module => $module, _api_wrapper => $api_wrapper, _properties => undef, _id => $project_id }, $class;

    my $ip = Webservice::OVH::Cloud::Project::IP->_new($api_wrapper, $self, $module);
    $self->{ip} = $ip;
    
    $self->properties;

    return $self;
}

sub id {

    my ($self) = @_
    ;
    return $self->{_id};
}

=head2 properties

Returns the raw properties as a hash. 
This is the original return value of the web-api. 

=over

=item * Return: HASH

=item * Synopsis: my $properties = $project->properties;

=back

=cut

sub properties {

    my ($self) = @_;

    my $api      = $self->{_api_wrapper};
    my $id       = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/cloud/project/$id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub description {

    my ($self) = @_;

    return $self->{_properties}->{description};
}

sub unleash {

    my ($self) = @_;

    return $self->{_properties}->{unleash};
}

sub order {

    my ($self) = @_;

    my $order_id = $self->{_properties}->{orderId};

    if ($order_id) {

        return $self->{_module}->me->order($order_id);
    }

    return undef;
}

sub status {

    my ($self) = @_;

    return $self->{_properties}->{status};
}

sub access {

    my ($self) = @_;

    return $self->{_properties}->{access};
}

=head2 change

Changes the project.

=over

=item * Parameter: %params - key => value description

=item * Synopsis: $project->change(description => 'Beschreibung');

=back

=cut

sub change {

    my ( $self, %params ) = @_;

    my $api  = $self->{_api_wrapper};
    my $id   = $self->id;
    my $body = {};
    $body->{description} = $params{description} if exists $params{description};
    my $response = $api->rawCall( method => 'put', path => "/cloud/project/$id", body => $body, noSignature => 0 );
    croak $response->error if $response->error;
}

=head2 vrack

Get vrack where this project is associated.

=over

=item * Return: HASH

=item * Synopsis: $project->vrack;

=back

=cut

sub vrack {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $id  = $self->id;

    my $response = $api->rawCall( method => 'put', path => "/cloud/project/$id/vrack", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}



1;
