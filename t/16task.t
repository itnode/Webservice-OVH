use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok( $api, "module ok" );

#TODO
# At the moment only contact change tasks are implemented. 
# This tasks can't be tested, because a contact_change to another account has to be initialized

done_testing();