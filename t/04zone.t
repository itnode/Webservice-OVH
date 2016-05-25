use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api_examples = Webservice::OVH->new_from_json("../credentials.json");

my $example_zone = $api_examples->domain->zones->[0];

my $api_testing = Webservice::OVH->new_from_json("../credentials.json");

# Check if examples exist and test the _exists methods
ok( $api_testing->domain->service_exists( $example_zone->name ), "check example zone" );

ok( $example_zone->properties,    "ok properties" );
ok( $example_zone->service_infos, "service_infos ok" );
ok( $example_zone->name,          "name ok" );
ok( $example_zone->records, "records ok" );

done_testing();
