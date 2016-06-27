package Webservice::OVH::Cloud::Project::IP;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Cloud::Project::IP::Failover;

=head2 _new

Internal Method to create the ip object.
This method is not ment to be called directly.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $project - root project

=item * Return: L<Webservice::OVH::Cloud::Project::IP>

=item * Synopsis: Webservice::OVH::Cloud::Project::IP->_new($ovh_api_wrapper, $id, $module);

=back

=cut

sub _new {

    my ( $class, $api_wrapper, $project, $module ) = @_;

    croak "Missing project" unless $project;

    my $self = bless { module => $module, _api_wrapper => $api_wrapper, _project => $project, _available_failovers => [], _failovers => {} }, $class;

    return $self;
}

sub project {

    my ($self) = @_;

    return $self->{_project};
}

=head2 failover_exists

Returns 1 if failover is available for the connected account, 0 if not.

=over

=item * Parameter: $failover_id - api id, $no_recheck - (optional)only for internal usage 

=item * Return: VALUE

=item * Synopsis: print "failover exists" if $project->ip->failover_exists(1234);

=back

=cut

sub failover_exists {

    my ( $self, $failover_id, $no_recheck ) = @_;

    if ( !$no_recheck ) {

        my $api        = $self->{_api_wrapper};
        my $project_id = $self->project->id;
        my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/ip/failover", noSignature => 0 );
        croak $response->error if $response->error;

        my $list = $response->content;

        return ( grep { $_ eq $failover_id } @$list ) ? 1 : 0;

    } else {

        my $list = $self->{_avaiable_projects};

        return ( grep { $_ eq $failover_id } @$list ) ? 1 : 0;
    }
}

=head2 failovers

Produces an array of all available failovers that are connected to the project.

=over

=item * Return: ARRAY

=item * Synopsis: my $ips = $project->ip->failovers;

=back

=cut

sub failovers {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $project_id = $self->project->id;
    my $response   = $api->rawCall( method => 'get', path => "/cloud/project/$project_id/ip/failover", noSignature => 0 );
    croak $response->error if $response->error;

    my $failover_array = $response->content;
    my $failovers      = [];
    $self->{_available_failovers} = $failover_array;

    foreach my $failover_hash (@$failover_array) {

        my $failover_id = $failover_hash->{id};
        if ( $self->failover_exists( $failover_id, 1 ) ) {
            my $failover = $self->{_failovers}{$failover_id} = $self->{_failovers}{$failover_id} || Webservice::OVH::Cloud::Project::IP::Failover->_new( $api, $self->project, $failover_id, $self->{_module} );
            push @$failovers, $failover;
        }
    }

    return $failovers;
}

=head2 failover

Returns a single failover by id

=over

=item * Parameter: $failover_id - api id

=item * Return: L<Webservice::OVH::Cloud::Project::IP::Failover>

=item * Synopsis: my $failover = $project->ip->failover(1234);

=back

=cut

sub failover {

    my ( $self, $failover_id ) = @_;

    if ( $self->failover_exists($failover_id) ) {

        my $api = $self->{_api_wrapper};
        my $failover = $self->{_failovers}{$failover_id} = $self->{_failovers}{$failover_id} || Webservice::OVH::Cloud::Project::IP::Failover->_new( $api, $self->project, $failover_id, $self->{_module} );

        return $failover;
    } else {

        carp "Failover $failover_id doesn't exists";
        return undef;
    }
}
1;
