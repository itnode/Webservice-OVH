package Webservice::OVH::Domain::Zone::Record;

=encoding utf-8

=head1 NAME

Webservice::OVH::Domain::Zone::Record

=head1 SYNOPSIS

use Webservice::OVH;

my $ovh = Webservice::OVH->new_from_json("credentials.json");

my $zone = $ovh->domain->zone("myzone.de");

my $a_record = $zone->new_record(field_type => 'A', target => '0.0.0.0', ttl => 1000 );
my $mx_record = $zone->new_record(field_type => 'MX', target => '1 my.mail.server.de.');

my $records = $zone->records(filed_type => 'A', sub_domain => 'www');

foreach my $record (@$records) {

    $record->change( target => '0.0.0.0' );
    $record->zone->refresh;
    $record->change( sub_domain => 'www', refresh => 'true' );
}

$record->delete('true');

print "Not Valid anymore" unless $record->is_valid;

=head1 DESCRIPTION

Provides all api Record Methods available in the api.
Delete deletes the record object in the api and makes the object invalid.
No actions be done with it, when it is invalid.

=head1 METHODS

=over
=item * _new_existing
=item * _new
=item * is_valid
=item * _is_valid
=item * id
=item * zone
=item * properties
=item * field_type
=item * sub_domain
=item * target
=item * ttl
=item * delete
=item * change
=back

=cut

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

=head2 _new_existing

Internal Method to create a Record object.
This method should never be called directly.

=over
=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $zone - parent zone Objekt, $record_id => api intern id
=item * Return: L<Webservice::OVH::Domain::Zone::Record>
=item * Synopsis: Webservice::OVH::Domain::Zone::Record->_new_existing($ovh_api_wrapper, $module, $zone, $record_id);
=back

=cut

sub _new_existing {

    my ( $class, $api_wrapper, $module, $zone, $record_id ) = @_;

    die "Missing record_id" unless $record_id;
    my $zone_name = $zone->name;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $porperties = $response->content;
        my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $record_id, _properties => $porperties, _zone => $zone }, $class;

        return $self;
    } else {

        return undef;
    }
}

=head2 _new

Internal Method to create the zone object.
This method should never be called directly.

=over
=item * Parameter: $api_wrapper - ovh api wrapper object, $module - root object, $zone - parent zone, %params - key => value
=item * Return: L<Webservice::OVH::Domain::Zone::Record>
=item * Synopsis: Webservice::OVH::Domain::Zone::Recrod->_new($ovh_api_wrapper, $module, $zone_name, target => '0.0.0.0', field_type => 'A', sub_domain => 'www');
=back

=cut

sub _new {

    my ( $class, $api_wrapper, $module, $zone, %params ) = @_;

    my @keys_needed = qw{ field_type target };

    die "Missing zone" unless $zone;

    if ( my @missing_parameters = grep { not $params{$_} } @keys_needed ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $zone_name = $zone->name;
    my $body      = {};
    $body->{subDomain} = $params{sub_domain} if exists $params{sub_domain};
    $body->{target}    = $params{target};
    $body->{ttl}       = $params{ttl} if exists $params{ttl};
    $body->{fieldType} = $params{field_type} if exists $params{field_type};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/domain/zone/$zone_name/record", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $record_id  = $response->content->{id};
    my $properties = $response->content;

    my $refresh = $params{'refresh'} || 'false';
    $zone->refresh if $refresh eq 'true';

    my $self = bless { _module => $module, _valid => 1, _api_wrapper => $api_wrapper, _id => $record_id, _properties => $properties, _zone => $zone }, $class;

    return $self;
}

=head2 is_valid

When this record is deleted on the api side, this method returns 0.

=over
=item * Return: L<VALUE>
=item * print "Valid" if $record->is_valid;
=back

=cut

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $record_id = $self->id;
    carp "Record $record_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub zone {

    my ($self) = @_;

    return $self->{_zone};
}

sub properties {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->zone->name;
    my $record_id = $self->id;
    my $response  = $api->rawCall( method => 'get', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;
    return $self->{_properties};
}

sub field_type {

    my ($self) = @_;

    return $self->{_properties}->{fieldType};
}

sub sub_domain {

    my ($self) = @_;

    return $self->{_properties}->{subDomain};
}

sub target {

    my ($self) = @_;

    return $self->{_properties}->{target};
}

sub ttl {

    my ($self) = @_;

    return $self->{_properties}->{ttl};
}

sub delete {

    my ( $self, $refresh ) = @_;

    return unless $self->_is_valid;

    my $api       = $self->{_api_wrapper};
    my $zone_name = $self->{_zone}->name;
    my $record_id = $self->id;
    my $response  = $api->rawCall( method => 'delete', path => "/domain/zone/$zone_name/record/$record_id", noSignature => 0 );
    croak $response->error if $response->error;

    $refresh ||= 'false';
    $self->zone->refresh if $refresh eq 'true';
    $self->{_valid} = 0;
}

sub change {

    my ( $self, %params ) = @_;

    return unless $self->_is_valid;

    if ( scalar keys %params != 0 ) {

        my $api       = $self->{_api_wrapper};
        my $zone_name = $self->{_zone}->name;
        my $record_id = $self->id;
        my $body      = {};
        $body->{subDomain} = $params{sub_domain} if exists $params{sub_domain};
        $body->{target}    = $params{target}     if exists $params{target};
        $body->{ttl}       = $params{ttl}        if exists $params{ttl};
        my $response = $api->rawCall( method => 'put', path => "/domain/zone/$zone_name/record/$record_id", body => $body, noSignature => 0 );
        croak $response->error if $response->error;

        my $refresh = $params{refresh} || 'false';
        $self->zone->refresh if $refresh eq 'true';
        $self->properties;
    }
}

1;
