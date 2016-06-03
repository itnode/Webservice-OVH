use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok($api, "module ok");

my $cart = $api->order->new_cart( ovh_subsidiary => 'DE' );

my $carts = $api->order->carts;
my @found_cart = grep { $_->id eq $cart->id } @$carts;
my $search_cart = $api->order->cart($cart->id);

ok( $cart, 'new cart ok');
ok( $carts && ref $carts eq 'ARRAY', 'new cart ok');
ok( scalar @found_cart > 0, 'cart in list ok' );
ok( $search_cart, 'found cart ok' );

my $dt_expire = DateTime->now->add(days => 1);
$cart->change( description => 'Ein Einkaufswagen', expire => Webservice::OVH::Helper->format_datetime($dt_expire) );
warn $@ if $@;

ok( $cart->description eq 'Ein Einkaufswagen', 'change description ok' );
ok( $cart->expire, 'change expire ok' );


$cart->delete;

done_testing();