use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");

ok ( $api, "api object creation" );
ok ( $api->domain, "domain object exists" );
ok ( $api->order, "order object exists" );
ok ( $api->me, "me object exists" );
ok ( $api->email, "email object exists" );

done_testing();