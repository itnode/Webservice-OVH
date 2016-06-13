use strict;
use warnings;
use DDP;
use List::Util qw(first);
use DateTime;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";
use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");

my $zones = $api->zones;

foreach my $zone (@$zones) {
    
    my $www_a_records = $zone->records(field_type => 'A', subdomain => 'www');
    my $base_a_records = $zone->records(field_type => 'A', subdomain => '');
    
    foreach my $record (@$www_a_records, @$base_a_records) {
        
        $record->change(target => '149.202.75.11', ttl => 3600);
    }
}