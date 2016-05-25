use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 10;

use Webservice::OVH;

my $api_examples = Webservice::OVH->new_from_json("../credentials.json");

my $example_service = $api_examples->domain->services->[0]->name;
my $example_zone    = $api_examples->domain->zones->[0]->name;

my $api_testing = Webservice::OVH->new_from_json("../credentials.json");

# Check if examples exist and test the _exists methods

ok( $api_testing->domain->service_exists($example_service), "check example service" );
ok( $api_testing->domain->zone_exists($example_zone),       "check example zone" );

sub test_single_calls {

    # positive test
    my $service = $api_testing->domain->service($example_service);
    my $zone    = $api_testing->domain->zone($example_zone);

    ok( $service, "getting a service" );
    ok( $zone,    "getting a zone" );

    #negative test
    my $no_service = $api_testing->domain->service("xyz.abc");
    my $no_zone    = $api_testing->domain->zone("xyz.abc");

    ok( !$no_service, "getting no service" );
    ok( !$no_zone,    "getting no zone" );
}

sub test_list_calls {

    my $services = $api_testing->domain->services;
    my $zones    = $api_testing->domain->zones;

    ok( scalar @$services > 0, "servicelist has content" );
    ok( scalar @$zones > 0,    "zonelist has content" );

    ok( scalar @$services == scalar @{ $api_testing->domain->{_aviable_services} }, "check with intern list" );
    ok( scalar @$zones == scalar @{ $api_testing->domain->{_aviable_zones} },       "check with intern list $zones" );
}

test_single_calls;
test_list_calls;

done_testing();
