package Webservice::OVH::Me;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { _api_wrapper => $api_wrapper, _contacts => {}, _tasks_contact_change => {} }, $class;

    return $self;
}

sub contacts {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/contact", noSignature => 0 );
    croak $response->error if $response->error;

    my $contact_ids = $response->content;
    my $contacts    = [];

    foreach my $contact_id (@$contact_ids) {

        my $contact = $self->{_contacts}{$contact_id} = $self->{_contacts}{$contact_id} || Webservice::OVH::Me::Contact->_new_existing( $api, $contact_id );
        push @$contacts, $contact;
    }

    return $contacts;
}

sub contact {

    my ( $self, $contact_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $contact = $self->{_contacts}{$contact_id} = $self->{_contacts}{$contact_id} || Webservice::OVH::Me::Contact->_new_existing( $api, $contact_id );

    return $contact;
}

sub tasks_contact_change {

    my ($self) = @_;

    my $api = $self->{_api_wrapper};
    my $response = $api->rawCall( method => 'get', path => "/me/task/contactChange", noSignature => 0 );
    croak $response->error if $response->error;

    my $task_ids = $response->content;
    my $tasks    = [];

    foreach my $task_id (@$task_ids) {

        my $task = $self->{_tasks_contact_change}{$task_id} = $self->{_tasks_contact_change}{$task_id} || Webservice::OVH::Me::Task->_new( $api, "contact_change", $task_id );
        push @$tasks, $task;
    }

    return $tasks;
}

sub task_contact_change {

    my ( $self, $task_id ) = @_;

    my $api = $self->{_api_wrapper};
    my $task = $self->{_tasks_contact_change}{$task_id} = $self->{_tasks_contact_change}{$task_id} || Webservice::OVH::Me::Task->_new( $api, "contact_change", $task_id );

    return $task;

}

1;
