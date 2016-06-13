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
    
    my $mx_records = $zone->records(field_type => 'MX');
    
    foreach my $record (@$mx_records) {
        
        $record->change(target => 'mailserver.nak.org');
    }
}