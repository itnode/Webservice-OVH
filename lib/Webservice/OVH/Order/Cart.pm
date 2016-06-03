package Webservice::OVH::Order::Cart;

use strict;
use warnings;
use Carp qw{ carp croak };

our $VERSION = 0.1;

use Webservice::OVH::Order::Cart::Item;

sub _new_existing {

    my ( $class, $api_wrapper, $card_id ) = @_;

    die "Missing card_id" unless $card_id;
    my $response = $api_wrapper->rawCall( method => 'get', path => "/order/cart/$card_id", noSignature => 0 );
    carp $response->error if $response->error;

    if ( !$response->error ) {

        my $properties = $response->content;
        my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $card_id, _properties => $properties, _items => {} }, $class;

        return $self;

    } else {

        return undef;
    }
}

sub _new {

    my ( $class, $api_wrapper, %params ) = @_;

    croak "Missing ovh_subsidiary" unless exists $params{ovh_subsidiary};
    my $body = {};
    $body->{description} = $params{description} if exists $params{description};
    $body->{expire}      = $params{expire}      if exists $params{expire};
    $body->{ovhSubsidiary} = $params{ovh_subsidiary};
    my $response = $api_wrapper->rawCall( method => 'post', path => "/order/cart", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $card_id    = $response->content->{cartId};
    my $properties = $response->content;

    my $response_assign = $api_wrapper->rawCall( method => 'post', path => "/order/cart/$card_id/assign", body => {}, noSignature => 0 );
    croak $response_assign->error if $response_assign->error;

    my $self = bless { _valid => 1, _api_wrapper => $api_wrapper, _id => $card_id, _properties => $properties, _items => {} }, $class;

    return $self;
}

sub properties {

    my ($self) = @_;

    return $self->{_properties};
}

sub description {
    
    my ($self) = @_;
    
    return $self->{_properties}->{description};
}

sub expire {
    
    my ($self) = @_;
    
    return $self->{_properties}->{expire};
}

sub read_only {
    
    my ($self) = @_;
    
    return $self->{_properties}->{readOnly} ? 1 : 0;
}

sub change {

    my ( $self, %params ) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    if ( exists $params{description} || exists $params{expire} ) {

        my $body = {};
        $body->{description} = $params{description} if $params{description};
        $body->{expire}      = $params{expire}      if $params{expire};

        my $response = $api->rawCall( method => 'put', path => "/order/cart/$cart_id", body => $body, noSignature => 0 );
        croak $response->error if $response->error;

        $self->properties;
    }
}

sub is_valid {

    my ($self) = @_;

    return $self->{_valid};
}

sub _is_valid {

    my ($self) = @_;

    my $cart_id = $self->id;
    carp "Cart $cart_id is not valid anymore" unless $self->is_valid;
    return $self->is_valid;
}

sub delete {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'delete', path => "/order/cart/$cart_id", noSignature => 0 );
    croak $response->error if $response->error;

    $self->{_valid} = 0;
}

sub id {

    my ($self) = @_;

    return $self->{_id},;
}

sub offers_domain {

    my ( $self, $domain ) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => sprintf( "/order/cart/%s/domain?domain=%s", $cart_id, $domain ), noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_domain {

    my ( $self, $domain, %params ) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    croak "Missing domain parameter" unless $domain;

    my $body = {};
    $body->{duration} = $params{duration} if exists $params{duration};
    $body->{offerId}  = $params{offer_id} if exists $params{offer_id};
    $body->{quantity} = $params{quantity} if exists $params{quantity};
    $body->{domain}   = $domain;

    my $response = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/domain", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $item_id = $response->content->{itemId};
    my $item = Webservice::OVH::Order::Cart::Item->_new( $api, $self, $item_id );

    my $owner = $params{owner_contact};
    my $admin = $params{admin_account};
    my $tech  = $params{tech_account};

    if ($owner) {
        my $config_preset_owner = { label => "OWNER_CONTACT", value => $owner };
        my $response_product_set_config_owner = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_owner, noSignature => 0 );
        my $config2 = $response_product_set_config_owner->content unless $response_product_set_config_owner->error;
        croak $response_product_set_config_owner->error if $response_product_set_config_owner->error;
    }

    if ($admin) {

        my $config_preset_admin = { label => "ADMIN_ACCOUNT", value => $admin };
        my $response_product_set_config_admin = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_admin, noSignature => 0 );
        my $config3 = $response_product_set_config_admin->content unless $response_product_set_config_admin->error;
        croak $response_product_set_config_admin->error if $response_product_set_config_admin->error;
    }

    if ($tech) {

        my $config_preset_tech = { label => "TECH_ACCOUNT", value => $tech };
        my $response_product_set_config_tech = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_tech, noSignature => 0 );
        my $config4 = $response_product_set_config_tech->content unless $response_product_set_config_tech->error;
        croak $response_product_set_config_tech->error if $response_product_set_config_tech->error;
    }

    return $item;
}

sub offers_domain_transfer {

    my ( $self, $domain ) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => sprintf( "/order/cart/%s/domainTransfer?domain=%s", $cart_id, $domain ), noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub add_transfer {

    my ( $self, $domain, %params ) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    croak "Missing domain parameter" unless $domain;
    croak "Missing auth_info" unless exists $params{auth_info};

    my $body = {};
    $body->{duration} = $params{duration} if exists $params{duration};
    $body->{offerId}  = $params{offer_id} if exists $params{offer_id};
    $body->{quantity} = $params{quantity} if exists $params{quantity};
    $body->{domain}   = $domain;

    my $response = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/domainTransfer", body => $body, noSignature => 0 );
    croak $response->error if $response->error;

    my $item_id = $response->content->{itemId};
    my $item = Webservice::OVH::Order::Cart::Item->_new( $api, $self, $item_id );

    return unless $item;

    my $auth_info = $params{auth_info};
    my $owner     = $params{owner_contact};
    my $admin     = $params{admin_account};
    my $tech      = $params{tech_account};

    my $config_preset = { label => "AUTH_INFO", value => $auth_info };
    my $response_product_set_config = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset, noSignature => 0 );
    my $config1 = $response_product_set_config->content unless $response_product_set_config->error;
    croak $response_product_set_config->error if $response_product_set_config->error;

    if ($owner) {
        my $config_preset_owner = { label => "OWNER_CONTACT", value => $owner };
        my $response_product_set_config_owner = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_owner, noSignature => 0 );
        my $config2 = $response_product_set_config_owner->content unless $response_product_set_config_owner->error;
        croak $response_product_set_config_owner->error if $response_product_set_config_owner->error;
    }

    if ($admin) {
        my $config_preset_admin = { label => "ADMIN_ACCOUNT", value => $admin };
        my $response_product_set_config_admin = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_admin, noSignature => 0 );
        my $config3 = $response_product_set_config_admin->content unless $response_product_set_config_admin->error;
        croak $response_product_set_config_admin->error if $response_product_set_config_admin->error;
    }

    if ($tech) {
        my $config_preset_tech = { label => "TECH_ACCOUNT", value => $tech };
        my $response_product_set_config_tech = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/item/$item_id/configuration", body => $config_preset_tech, noSignature => 0 );
        my $config4 = $response_product_set_config_tech->content unless $response_product_set_config_tech->error;
        croak $response_product_set_config_tech->error if $response_product_set_config_tech->error;
    }

    return $item;
}

sub info_checkout {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/checkout", noSignature => 0 );
    croak $response->error if $response->error;

    return $response->content;
}

sub checkout {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api     = $self->{_api_wrapper};
    my $cart_id = $self->id;

    my $response = $api->rawCall( method => 'post', path => "/order/cart/$cart_id/checkout", body => {}, noSignature => 0 );
    croak $response->error if $response->error;

    my $order_id = $response->content->{orderId};
    my $order = Webservice::OVH::Me::Order->_new( $api, $order_id );

    return $order;
}

sub items {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $api      = $self->{_api_wrapper};
    my $cart_id  = $self->id;
    my $response = $api->rawCall( method => 'get', path => "/order/cart/$cart_id/item", noSignature => 0 );
    croak $response->error if $response->error;

    my $item_ids = $response->content;
    my $items    = [];

    foreach my $item_id (@$item_ids) {

        my $item = $self->{_items}{$item_id} = $self->{_items}{$item_id} || Webservice::OVH::Order::Cart::Item->_new( $api, $self, $item_id );
        push @$items, $item;
    }

    return $items;
}

sub item {

    my ( $self, $item_id ) = @_;

    return unless $self->_is_valid;

    my $api = $self->{_api_wrapper};
    my $item = $self->{_items}{$item_id} = $self->{_items}{$item_id} || Webservice::OVH::Domain::Service->_new( $api, $self, $item_id );
    return $item;
}

sub clear {

    my ($self) = @_;

    return unless $self->_is_valid;

    my $items = $self->items;

    foreach my $item (@$items) {

        $item->delete;
    }
}

1;

