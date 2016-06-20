package Webservice::OVH::Email::Domain::Domain::Redirection;

=encoding utf-8

=head1 NAME

Webservice::OVH::Email::Domain::Domain::Redirection

=head1 SYNOPSIS

use Webservice::OVH;

my $ovh = Webservice::OVH->new_from_json("credentials.json");

my $email_domain = $ovh->email->domain->domain('testdomain.de');

my $redirection = $email_domain->new_redirection(from => 'test@test.de', to => 'test2@test.de', local_copy => 'false');

=head1 DESCRIPTION

Provides the ability to create, delete and change redirections for an email-domain.

=head1 METHODS

=cut

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

=head2 _new_existing

Internal Method to create a Redirection object.
This method should never be called directly.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $domain - parent domain Objekt, $redirection_id => api intern id

=item * Return: L<Webservice::OVH::Email::Domain::Domain::Redirection>

=item * Synopsis: Webservice::OVH::Email::Domain::Domain::Redirection->_new_existing($ovh_api_wrapper, $domain, $redirection_id, $module);

=back

=cut

sub _new_existing {

    my ( $class, $api_wrapper, $domain, $redirection_id, $module ) = @_;

    die "Missing redirection_id" unless $redirection_id;
    my $domain_name = $domain->name;
    my $response = $api_wrapper->rawCall( module => $module, method => 'get', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;

        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $redirection_id, _properties => $porperties, _domain => $domain }, $class;

        return $self;

    } else {

        return undef;
    }
}

=head2 _new

Internal Method to create the Redirection object.
This method should never be called directly.

=over

=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $domain - parent domain, %params - key => value

=item * Return: L<Webservice::OVH::Email::Domain::Domain::Redirection>

=item * Synopsis: Webservice::OVH::Email::Domain::Domain::Redirection->_new($ovh_api_wrapper, $domain, $module, from => 'from@test.com', to => 'to@test.com', local_copy => 'false');

=back

=cut

sub _new {

    my ( $class, $api_wrapper, $domain, $module, %params ) = @_;

    my @keys_needed = qw{ from local_copy to };

    die "Missing domain" unless $domain;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $domain_name = $domain->name;
    my $body        = {};
    $body->{from}      = $params{from};
    $body->{to}        = $params{to};
    $body->{localCopy} = $params{local_copy};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/email/domain/$domain_name/redirection/", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $redirection = $domain->redirections( from => $params{from}, to => $params{to} )->[0];
    my $properties = $redirection->properties;

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $redirection->id, _properties => $properties, _domain => $domain }, $class;

    return $self;
}

=head2 is_valid

When this redirection is deleted on the api side, this method returns 0.

=over

=item * Return: VALUE

=item * Synopsis: print "Valid" if $redirection->is_valid;

=back

=cut

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

=head2 _is_valid

Intern method to check validity.
Difference is that this method carps an error.

=over

=item * Return: VALUE

=item * Synopsis: $redirection->_is_valid;

=back

=cut

sub _is_valid {

    my ($self) = @_;

    my $redirection_id = $self->id;
    carp "Redirection $redirection_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

=head2 id

Returns the api id. 

=over

=item * Return: VALUE

=item * Synopsis: my $id = $redirection->id;

=back

=cut

sub id {

    my ($self) = @_;

    return $self->{_id};
}

=head2 domain

Returns the email-domain this redirection is attached to. 

=over

=item * Return: L<Webservice::Email::Domain::Domain>

=item * Synopsis: my $email_domain = $redirection->domain;

=back

=cut

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

=head2 properties

Returns the raw properties as a hash. 
This is the original return value of the web-api. 

=over

=item * Return: HASH

=item * Synopsis: my $properties = $record->properties;

=back

=cut

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api            = $self->{_api_wrapper};
    my $domain_name    = $self->domain->name;
    my $redirection_id = $self->id;
    my $response       = $api->rawCall( method => 'get', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

=head2 field_type

Exposed property value. 

=over

=item * Return: VALUE

=item * Synopsis: my $from = $record->from;

=back

=cut

sub from {

    my ($self) = @_;

    return $self->{_properties}->{from};
}

=head2 to

Exposed property value. 

=over

=item * Return: VALUE

=item * Synopsis: my $to = $record->to;

=back

=cut

sub to {

    my ($self) = @_;

    return $self->{_properties}->{to};
}

=head2 delete

Deletes the redirection api sided and sets this object invalid.

=over

=item * Synopsis: $redirection->delete;

=back

=cut

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api            = $self->{_api_wrapper};
    my $domain_name    = $self->domain->name;
    my $redirection_id = $self->id;
    my $response       = $api->rawCall( method => 'delete', path => "/email/domain/$domain_name/redirection/$redirection_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

=head2 change

Changes the redirection

=over

=item * Parameter: %params - key => value to

=item * Synopsis: $redirection->change(to => 'test@test.de');

=back

=cut

sub change {

    my ( $self, $to ) = @_;
    return unless $self->_is_valid;

    croak "Missing to as parameter" unless $to;

    my $api            = $self->{_api_wrapper};
    my $domain_name    = $self->domain->name;
    my $redirection_id = $self->id;
    my $body           = {};
    $body->{to} = $to;
    my $response = $api->rawCall( method => 'post', path => "/email/domain/$domain_name/redirection/$redirection_id/changeRedirection", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $redirection = $self->domain->redirections( from => $self->from, to => $to )->[0];
    $self->{_properties} = $redirection->properties;
    $self->{_id}         = $redirection->id;
}

1;
