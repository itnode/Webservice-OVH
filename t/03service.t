use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 5;

use Webservice::OVH;

my $api_examples = Webservice::OVH->new_from_json("../credentials.json");

my $example_service = $api_examples->domain->services->[0];

my $api_testing = Webservice::OVH->new_from_json("../credentials.json");

# Check if examples exist and test the _exists methods
ok( $api_testing->domain->service_exists( $example_service->name ), "check example service" );

ok( $example_service->properties,    "ok properties" );
ok( $example_service->service_infos, "service_infos ok" );
ok( $example_service->name,          "name ok" );
ok( $example_service->owner,         "owner ok" );

done_testing();