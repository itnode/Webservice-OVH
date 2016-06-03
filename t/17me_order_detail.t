use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok( $api, "module ok" );

my $orders = $api->me->orders;
my $order = $orders->[0];
ok( $orders && ref $orders eq 'ARRAY', 'orders ok' );
ok( $orders, 'order ok' );

my $details = $order->details;
my $detail = $details->[0];
ok( $details && ref $details eq 'ARRAY', 'details ok' );
ok( $detail, 'order ok' );

ok( $detail->id, 'id ok');
ok( $detail->properties && ref $detail->properties eq 'HASH', 'properties ok');
ok( $detail->order && ref $detail->order eq 'Webservice::OVH::Me::Order', 'order ok');
ok( $detail->domain, 'id ok');
ok( $detail->quantity, 'id ok');
ok( $detail->total_price, 'id ok');
ok( $detail->unit_price, 'id ok');

done_testing();