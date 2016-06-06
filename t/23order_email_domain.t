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

my $services = $api->order->email->domain->available_services;
ok( $services && ref $services eq 'ARRAY' && scalar @$services > 0, 'available_services ok');

my $allowed_durations = $api->order->email->domain->allowed_durations($services->[0], '100');
ok( $allowed_durations && ref $allowed_durations eq 'ARRAY' && scalar @$allowed_durations > 0, 'allowed_durations ok');

my $info = $api->order->email->domain->info($services->[0], '100', $allowed_durations->[0]);
ok($info && ref $info eq 'HASH', 'info ok' );

done_testing();