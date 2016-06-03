use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok($api, "module ok");

ok( $api->order->carts && ref $api->order->carts eq 'ARRAY', 'carts ok');
ok( $api->order->hosting, 'hosting ok' );
ok( $api->order->email, 'email ok' );

done_testing();