package Webservice::OVH::Domain::Service;

use strict;
use warnings;

our $VERSION = 0.1;

sub new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { api_wrapper => $api_wrapper, data => {}, type => "" }, $class;

    return $self;
}

sub accept {

    my ( $self, $token ) = @_;

}

sub refuse {

    my ( $self, $token ) = @_;

}

sub resend_email {

    my ($self) = @_;

}

1;
