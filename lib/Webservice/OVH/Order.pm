package Webservice::OVH::Order;

use strict;
use warnings;

our $VERSION = 0.1;

use Webservice::OVH::Order::Card;

sub new {
    
    my ( $class, $api_wrapper ) = @_;
    
    my $self = bless {api_wrapper => $api_wrapper}, $class;
    
    return $self;
}

sub new_card {
    
    my ( $self ) = @_;
    
    return undef;
}

sub cards {
    
    my ( $self ) = @_;
    
    return [];
}

sub card {
    
    my ( $self, $card_id ) = @_;
    
    return undef;
}


1;