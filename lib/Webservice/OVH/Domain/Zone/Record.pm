package Webservice::OVH::Domain::Zone::Record;

use strict;
use warnings;

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

sub new {

    my ( $class, $api_wrapper ) = @_;

    my $self = bless { api_wrapper => $api_wrapper, data => {}, id => undef }, $class;

    return $self;
}

sub delete {

    my ($self) = @_;
}

sub change {

    my ( $self, %params ) = @_;
}

1;
