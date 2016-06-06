use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

=head2

    new can't be tested, because an order is directly created when called

=cut

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok($api, "module ok");

ok ($api->order->hosting, 'hosting ok');
ok ($api->order->hosting->web, 'web ok');

done_testing();