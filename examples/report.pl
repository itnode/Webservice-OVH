use strict;
use warnings;
use DDP;
use List::Util qw(first);
use DateTime;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";
use Webservice::OVH;

my $target_file = $ARGV[0];

die "The script expects a target filepath for the report as argument" unless $target_file;

my $api = Webservice::OVH->new_from_json("../credentials.json");

my $services = $api->domain->services;

my $lines = ["Domain,Fieldtype,Target,TTL,Subdomain"];

foreach my $service (@$services) {
    
    if($api->domain->zone_exists($service->name)) {
        
        my $line = "";
        my $zone = $api->domain->zone($service->name);
        my $records_mx = $zone->records( field_type => 'MX' );
        my $records_a = $zone->records( field_type => 'A' );
        
        foreach my $record (@$records_mx, @$records_a) {
            
            $line = sprintf("%s, %s, %s, %s, %s\n", $service->name, $record->field_type, $record->target, $record->ttl, $record->sub_domain);
            push @$lines, $line;
        }
        
    } else {
        
        push @$lines, $service->name."\n";
    }
}

open(my $fh, '>', $target_file) or die "Could not open file '$target_file' $!";

foreach my $line (@$lines) {
    
    print $fh $line;
}

close $fh;