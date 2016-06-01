use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 3;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");

ok( $api,                "api ok" );
ok( $api->email,         "email object ok" );
ok( $api->email->domain, "email domain object ok" );

done_testing();

