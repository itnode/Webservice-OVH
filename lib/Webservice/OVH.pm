package Webservice::OVH;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

# api module provided by ovh
use OvhApi;

# sub-modules
use Webservice::OVH::Domain;
use Webservice::OVH::Me;
use Webservice::OVH::Order;
use Webservice::OVH::Email;

# other requirements
use JSON;
use File::Slurp qw(read_file);

=head1 NAME

Webservice::OVH

=head1 DESCRIPTION

The base object from which every api call is done.
The object structure represents the ovh api structure.
This module uses the perl api module provided by ovh 

=head1 METHODS

new_from_json
new
set_timeout
domain
me
order
email

=cut

=head2 new_from_json

Creates an api Object based on credentials in a json File

=head3 Parameter
=over

=item $file_json dir to json file

=back


=head3 JSON file
=over

=item application_key      is generated when creating an application via ovh web interface
=item application_secret   is generated when creating an application via ovh web interface
=item consumer_key         must be requested through ovh authentification
=item timeout              timeout in milliseconds, warning some request may take a while

=back

=cut

sub new_from_json {

    my ( $class, $file_json ) = @_;

    # slurp file
    my $json = read_file $file_json, { binmode => ':utf8' };

    # decode json
    my $Json = JSON->new->allow_nonref;
    my $data = $Json->decode($json);

    # check for missing parameters in the json file
    my @keys = qw{ application_key application_secret consumer_key };
    if ( my @missing_parameters = grep { not $data->{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }

    # Create internal objects to mirror the web api of ovh
    my $api_wrapper = OvhApi->new( 'type' => "https://eu.api.ovh.com/1.0", applicationKey => $data->{application_key}, applicationSecret => $data->{application_secret}, consumerKey => $data->{consumer_key} );
    my $domain      = Webservice::OVH::Domain->_new($api_wrapper);
    my $me          = Webservice::OVH::Me->_new($api_wrapper);
    my $order       = Webservice::OVH::Order->_new($api_wrapper);
    my $email       = Webservice::OVH::Email->_new($api_wrapper);

    # Timeout can be also set in the json file
    OvhApi->setRequestTimeout( timeout => $data->{timeout} || 120 );

    # Creating the class
    my $self = bless {}, $class;
    $self->{_domain}      = $domain;
    $self->{_me}          = $me;
    $self->{_order}       = $order;
    $self->{_api_wrapper} = $api_wrapper;
    $self->{_email}       = $email;

    return $self;
}

=head2 new

Create the api object. Credentials are given directly via %params

=head3 Parameter
=over

=item application_key     is generated when creating an application via ovh web interface
=item application_secret  is generated when creating an application via ovh web interface
=item consumer_key        must be requested through ovh authentification

=back
=cut

sub new {

    my ( $class, %params ) = @_;

    my @keys = qw{ application_key application_secret consumer_key };

    if ( my @missing_parameters = grep { not $params{$_} } @keys ) {

        croak "Missing parameter: @missing_parameters";
    }

    my $self = bless {}, $class;

    my $api_wrapper = OvhApi->new( 'type' => "https://eu.api.ovh.com/1.0", applicationKey => $params{application_key}, applicationSecret => $params{application_secret}, consumerKey => $params{consumer_key} );
    my $domain = Webservice::OVH::Domain->_new( $api_wrapper, $self );
    my $me = Webservice::OVH::Me->_new( $api_wrapper, $self );
    my $order = Webservice::OVH::Order->_new( $api_wrapper, $self );

    OvhApi->setRequestTimeout( timeout => $params{timeout} || 120 );

    $self->{_domain}      = $domain;
    $self->{_me}          = $me;
    $self->{_order}       = $order;
    $self->{_api_wrapper} = $api_wrapper;

    return $self;
}

=head2 set_timeout

Sets the timeout of the underlying LWP::Agent

=head3 Parameter
=over

=item timeout     in milliseconds

=back

=cut

sub set_timeout {

    my ( $class, $timeout ) = @_;

    OvhApi->setRequestTimeout( timeout => $timeout );
}

=head2 domain

Main access to all /domain/ api methods 

=cut

sub domain {

    my ($self) = @_;

    return $self->{_domain};
}

=head2 me

    Main access to all /me/ api methods 

=cut

sub me {

    my ($self) = @_;

    return $self->{_me};
}

=head2 order

Main access to all /order/ api methods 

=cut

sub order {

    my ($self) = @_;

    return $self->{_order};
}

=head2 email

Main access to all /email/ api methods 

=cut

sub email {

    my ($self) = @_;

    return $self->{_email};
}

1;
