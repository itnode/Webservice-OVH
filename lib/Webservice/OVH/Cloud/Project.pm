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

    my $self = bless { module => $module, _api_wrapper => $api_wrapper, _properties => undef, _id => $project_id, _instances => {}, _available_instances => [], _images => {}, _available_images => [] }, $class;
    my $instance = Webservice::OVH::Cloud::Project::Instance->_new_empty( $api_wrapper, $self, $module );
    my $network = Webservice::OVH::Cloud::Project::Instance->_new( wrapper => $api_wrapper, project => $self, module => $module );
    $self->{_instance} = $instance;
    $self->{_network} = $network;

    my $ip = Webservice::OVH::Cloud::Project::IP->_new( $api_wrapper, $self, $module );
    $self->{ip} = $ip;

    $self->properties;

    return $self;
}

sub id {

    my ($self) = @_;
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

=head2 instance_exists

Returns 1 if instance is available for the connected account, 0 if not.

=over

=item * Parameter: $instance_id - api id, $no_recheck - (optional)only for internal usage 

=item * Return: VALUE

=item * Synopsis: print "instance exists" if $project->instance_exists(1234);

=back

=cut

sub instance_exists {

    my ( $self, $instance_id, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api        = $self->{_api_wrapper};
        my $project_id = $self->id;
        my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/instance", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $instance_id } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_available_instances};

        return ( grep { $_ eq $instance_id } @$list ) ? 1 : 0;
    }
}

=head2 instances

Produces an array of all available instances that are connected to the project.

=over

=item * Return: ARRAY

=item * Synopsis: my $instances = $project->instances;

=back

=cut

sub instances {

    my ( $self, $region ) = @_;

    my $filter = Webservice::OVH::Helper->construct_filter( "region" => $region );

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => sprintf( "/cloud/project/$project_id/instance%s", $filter ), noSignature => 0 );
    croak $response->error if $response->error;

    my $instance_array = $response->content;
    my $instances      = [];
    $self->{_available_instances} = $instance_array;

    foreach my $instance_id (@$instance_array) {

        if ( $self->instance_exists( $instance_id, 1 ) ) {
            my $instance = $self->{_instances}{$instance_id} = $self->{_instances}{$instance_id} || Webservice::OVH::Cloud::Project::Instance->_new( $api, $self->project, $instance_id, $self->{_module} );
            push @$instances, $instance;
        }
    }

    return $instances;
}

=head2 instance

Returns a single instance by id

=over

=item * Parameter: $instance_id - api id

=item * Return: L<Webservice::OVH::Cloud::Project::Instance>

=item * Synopsis: my $instance = $project->instance(1234);

=back

=cut

sub instance {

    my ( $self, $instance_id ) = @_;

    if ( !$instance_id ) {

        return $self->{_instance};

    } else {

        if ( $self->instance_exists($instance_id) ) {

            my $api = $self->{_api_wrapper};
            my $instance = $self->{_instances}{$instance_id} = $self->{_instances}{$instance_id} || Webservice::OVH::Cloud::Project::Instance->_new( $api, $self->project, $instance_id, $self->{_module} );

            return $instance;
        } else {

            carp "Instance $instance_id doesn't exists";
            return undef;
        }
    }
}

sub create_instance {

    my ( $self, $params, $networks ) = @_;

    my $api = $self->{_api_wrapper};
    my $instance = Webservice::OVH::Cloud::Project::Instance->_new( $api, $self->{_module}, $self, $params, $networks );
}

sub regions {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/region", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub region {

    my ( $self, $region_name ) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/region/$region_name", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub flavors {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/flavor", noSignature => 0 );
    croak $response->error if $response->error;

    my @flavor_ids = grep { $_->{id} } @{ $response->content };

    return \@flavor_ids;
}

sub flavor {

    my ( $self, $flavor_id ) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/flavor/$flavor_id", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub image_exists {

    my ( $self, $image_id, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api        = $self->{_api_wrapper};
        my $project_id = $self->id;
        my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/image/$image_id", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $image_id } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_available_images};

        return ( grep { $_ eq $image_id } @$list ) ? 1 : 0;
    }
}

sub images {

    my ( $self, %filter ) = @_;

    my $filter = Webservice::OVH::Helper->construct_filter( "flavorType" => %filter{flavor_type}, "osType" => %filter{os_type}, "region" => %filter{region} );

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->id;
    my $response   = $api->rawCall( method => 'get', path => sprintf( "/cloud/project/$project_id/image%s", $filter ), noSignature => 0 );
    croak $response->error if $response->error;

    my $image_array = $response->content;
    my $images      = [];
    $self->{_available_images} = $image_array;

    foreach my $image_id (@$image_array) {

        if ( $self->instance_exists( $image_id, 1 ) ) {
            my $image = $self->{_images}{$image_id} = $self->{_images}{$image_id} || Webservice::OVH::Cloud::Project::Image->_new_existing( $api, $self->{_module}, $self, $image_id );
            push @$images, $image;
        }
    }

    return $images;
}

sub image {

    my ( $self, $image_id ) = @_;

    if ( $self->image_exists($image_id) ) {

        my $api = $self->{_api_wrapper};
        my $instance = $self->{_image}{$image_id} = $self->{_image}{$image_id} || Webservice::OVH::Cloud::Project::Image->_new_existing( $api, $self->{_module}, $self, $image_id );

        return $instance;
    } else {

        carp "Instance $image_id doesn't exists";
        return undef;
    }
}

sub network {
    
    my ( $self ) = @_;
    
    return $self->{_network};
}

1;
