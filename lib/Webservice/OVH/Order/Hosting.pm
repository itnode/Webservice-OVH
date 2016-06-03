package Webservice::OVH::Order::Hosting;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Hosting::Web;

sub _new {

    my ( $class, $api_wrapper ) = @_;
    
    my $web = Webservice::OVH::Order::Hosting::Web->_new($api_wrapper);

    my $self = bless { _api_wrapper => $api_wrapper, _web => $web }, $class;

    return $self;
}

sub web {
    
    my ($self) = @_;
    
    return $self->{_web};
}




1;