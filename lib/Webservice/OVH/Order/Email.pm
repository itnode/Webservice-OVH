package Webservice::OVH::Order::Email;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Email::Domain;

sub _new {
    
    my ( $class, $api_wrapper ) = @_;
    
    my $domain = Webservice::OVH::Order::Email::Domain->_new($api_wrapper);

    my $self = bless { _api_wrapper => $api_wrapper, _domain => $domain}, $class;

    return $self;
}

sub domain {
    
    my ($self) = @_;
    
    return $self->{_domain};
}

1;