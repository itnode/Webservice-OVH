use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 9;

use Webservice::OVH;

my $api_examples = Webservice::OVH->new_from_json("../credentials.json");

my $example_zone = $api_examples->domain->zones->[0];

my $api_testing = Webservice::OVH->new_from_json("../credentials.json");

# Check if examples exist and test the _exists methods
ok( $api_testing->domain->service_exists( $example_zone->name ), "check example zone" );

ok( $example_zone->properties,    "ok properties" );
ok( $example_zone->service_infos, "service_infos ok" );
ok( $example_zone->name,          "name ok" );
ok( $example_zone->records,       "records ok" );
ok( $example_zone->dnssec_supported == 0 || $example_zone->dnssec_supported == 1, "dnssec_supported ok" );
ok( $example_zone->has_dns_anycast == 0  || $example_zone->has_dns_anycast == 1,  "has_dns_anycast ok" );
ok( $example_zone->last_update && ref $example_zone->last_update eq 'DateTime', "last_update ok" );
ok( ref $example_zone->name_servers eq 'ARRAY', "name_servers ok" );

done_testing();
