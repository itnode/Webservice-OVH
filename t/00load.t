use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 15;

use_ok( 'Webservice::OVH' );
use_ok( 'OvhApi' );
use_ok( 'Webservice::OVH::Helper' );
use_ok( 'Webservice::OVH::Domain' );
use_ok( 'Webservice::OVH::Order' );
use_ok( 'Webservice::OVH::Me' );
use_ok( 'Webservice::OVH::Domain::Service' );
use_ok( 'Webservice::OVH::Domain::Zone' );
use_ok( 'Webservice::OVH::Domain::Zone::Record' );
use_ok( 'Webservice::OVH::Me::Contact' );
use_ok( 'Webservice::OVH::Me::Order' );
use_ok( 'Webservice::OVH::Me::Task' );
use_ok( 'Webservice::OVH::Me::Order::Details' );
use_ok( 'Webservice::OVH::Order::Card' );
use_ok( 'Webservice::OVH::Order::Card::Item' );

done_testing();




