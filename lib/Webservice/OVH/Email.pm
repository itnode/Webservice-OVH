package Webservice::OVH::Email;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Email::Domain;

sub _new {
    
    my ( $class, $api_wrapper ) = @_;
    
    my $self = bless { _api_wrapper => $api_wrapper }, $class;
    
    $self->{_domain} = Webservice::OVH::Email::Domain->_new($api_wrapper);

    return $self;
}

sub domain {
    
    my ($self) = @_;
    
    return $self->{_domain};
}



1;