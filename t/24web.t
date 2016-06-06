use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok($api, "module ok");

my $services = $api->domain->services;

my $info = $api->order->hosting->web->free_email_info($services->[0]->name);
ok($info, 'info ok');

done_testing();