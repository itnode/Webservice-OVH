package Webservice::OVH::Me::Contact;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

sub _new_existing {

    my ( $class, $api_wrapper, $contact_id ) = @_;

    die "Missing contact_id" unless $contact_id;

    my $response = $api_wrapper->rawCall( method => 'get', path => "/me/contact/$contact_id", noSignature => 0 );
    croak $response->error if $response->error;

    my $id         = $response->content->{id};
    my $porperties = $response->content;

    my $self = bless { _api_wrapper => $api_wrapper, _id => $id, _properties => $porperties }, $class;

    return $self;
}

sub id {

    my ($self) = @_;

    return $self->{_id};
}

sub properties {

    my ($self) = @_;

    my $api        = $self->{_api_wrapper};
    my $contact_id = $self->{_id};
    my $response   = $api->rawCall( method => 'get', path => "/me/contact/$contact_id", noSignature => 0 );
    croak $response->error if $response->error;
    $self->{_properties} = $response->content;

    return $self->{_properties};
}

sub address {

    my ($self) = @_;

    return $self->{_properties}->{address};
}

sub birth_city {

    my ($self) = @_;

    return $self->{_properties}->{birthCity};
}

sub birth_country {

    my ($self) = @_;

    return $self->{_properties}->{birthCountry};
}

sub birth_day {

    my ($self) = @_;

    my $str_datetime = $self->{_properties}->{birthDay}."T00:00:00+0000";
    my $datetime     = Webservice::OVH::Helper->parse_datetime($str_datetime);
    return $datetime;
}

sub birth_zip {

    my ($self) = @_;

    return $self->{_properties}->{birthZip};
}

sub cell_phone {

    my ($self) = @_;

    return $self->{_properties}->{cellPhone};
}

sub company_national_identification_number {

    my ($self) = @_;

    return $self->{_properties}->{companyNationalIdentificationNumber};
}

sub email {

    my ($self) = @_;

    return $self->{_properties}->{email};
}

sub fax {

    my ($self) = @_;

    return $self->{_properties}->{fax};
}

sub first_name {

    my ($self) = @_;

    return $self->{_properties}->{firstName};
}

sub gender {

    my ($self) = @_;

    return $self->{_properties}->{gender};
}

sub language {

    my ($self) = @_;

    return $self->{_properties}->{language};
}

sub last_name {

    my ($self) = @_;

    return $self->{_properties}->{lastName};
}

sub legal_form {

    my ($self) = @_;

    return $self->{_properties}->{legalForm};
}

sub national_identification_number {

    my ($self) = @_;

    return $self->{_properties}->{nationalIdentificationNumber};
}

sub nationality {

    my ($self) = @_;

    return $self->{_properties}->{nationality};
}

sub organisation_name {

    my ($self) = @_;

    return $self->{_properties}->{organisationName};
}

sub organisation_type {

    my ($self) = @_;

    return $self->{_properties}->{organisationType};
}

sub phone {

    my ($self) = @_;

    return $self->{_properties}->{phone};
}

sub vat {

    my ($self) = @_;

    return $self->{_properties}->{vat};
}

1;
