use strict;
use warnings;
use DDP;
use List::Util qw(first);
use DateTime;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";
use Webservice::OVH;

my $csv_file = $ARGV[0];
die "The script expects a filepath to a csv file as first argument" unless $csv_file;

sub load_csv {
    
    my ($file) = @_;
    
    my $domain_list = {};
    
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";

    while (my $row = <$fh>) {
        
        $row =~ s/\r\n//g;
        my @row = split(',', $row);
        my $object = { area => $row[0], domain => $row[1], status => $row[2], auth => $row[3] };
        $domain_list->{$row[1]} = $object;
    }
    
    close $fh;
    
    return $domain_list;
}

my $domains = load_csv($csv_file);
my $api = Webservice::OVH->new_from_json("../credentials.json");

$domains = {};
$domains->{"nak-haeusern.de"} = 1;
#$domains->{"nak-malsch.de"} = 1;



foreach my $domain_str (keys %$domains) {
    
    print STDERR $domain_str."\n";
    #next unless $api->domain->zone_exists($domain_str);
    my $zone = $api->domain->zone($domain_str);
    my $service = $api->domain->service($domain_str);
    
    my $records = $zone->records;
    #my $exclude = $zone->records(field_type => 'NS');
    
    p $records;
    
    #foreach my $record (@$records) {
        
        #next if grep {$_->id eq $record->id} @$exclude;
        
        #$record->delete;
    #}
    #print STDERR "records deleted\n";
    #$zone->new_record(field_type => 'A', target => '149.202.75.11', TTL => 3600, sub_domain => '', refresh => '');
    #$zone->new_record(field_type => 'MX', target => '1 mailserver.nak.org.', refresh => 'false');
    #$zone->new_record(field_type => 'CNAME', target => $domain_str.".", sub_domain => 'www', refresh => 'false');
    
    #$zone->refresh;
}