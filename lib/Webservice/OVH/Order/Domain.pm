package Webservice::OVH::Order::Domain;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Domain::Zone;

sub _new {

    my ( $class, $api_wrapper ) = @_;

    my $zone  = Webservice::OVH::Order::Domain::Zone->_new($api_wrapper);

    my $self = bless { _api_wrapper => $api_wrapper, _zone => $zone }, $class;

    return $self;
}

sub zone {
    
    my ($self) = @_;

    return $self->{_zone};
}

1;