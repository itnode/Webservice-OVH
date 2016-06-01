use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

=head2

    Method change_contact can't be tested
    Method only initializes the change_contact procedure
    This woul cause emails to be send and a new task

=cut

use Test::More tests => 14;

use Webservice::OVH;

my $api_examples = Webservice::OVH->new_from_json("../credentials.json");

my $example_service = $api_examples->domain->services->[0];

my $api_testing = Webservice::OVH->new_from_json("../credentials.json");

# Check if examples exist and test the _exists methods
ok( $api_testing->domain->service_exists( $example_service->name ), "check example service" );

ok( $example_service->properties,    "ok properties" );
ok( $example_service->service_infos, "service_infos ok" );
ok( $example_service->name,          "name ok" );
ok( $example_service->whois_owner,   "whois_owner ok" );
ok( $example_service->dnssec_supported == 0 || $example_service->dnssec_supported == 1, "dnssec_supported ok" );
ok( $example_service->domain, "domain ok" );
ok( $example_service->glue_record_ipv6_supported == 0     || $example_service->glue_record_ipv6_supported == 1,     "glue_record_ipv6_supported ok" );
ok( $example_service->glue_record_multi_ip_supported == 0 || $example_service->glue_record_multi_ip_supported == 1, "glue_record_multi_ip_supported ok" );
ok( $example_service->last_update && ref $example_service->last_update eq 'DateTime', "last_update ok" );
ok( $example_service->name_server_type, "name_server_type ok" );
ok( $example_service->offer,            "offer ok" );
ok( $example_service->owo_supported == 0 || $example_service->owo_supported == 1, "owner ok" );
ok( $example_service->transfer_lock_status, "transfer_lock_status ok" );

done_testing();
