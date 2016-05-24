package Webservice::OVH::Me;

use strict;
use warnings;

our $VERSION = 0.1;

use Webservice::OVH::Me::Contact;

sub _new {
    
    my ( $class, $api_wrapper ) = @_;
    
    my $self = bless {api_wrapper => $api_wrapper}, $class;
    
    return $self;
}

sub contacts {
    
    my ( $self ) = @_;
    
    return [];
}

sub contact {
    
    my ( $self, $contact_id ) = @_;
    
    return undef;
}




1;