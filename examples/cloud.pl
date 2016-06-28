use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

my $json_dir = $ENV{'API_CREDENTIAL_DIR'};

unless ( $json_dir && -e $json_dir ) { die 'No credential file found in $ENV{"API_CREDENTIAL_DIR"} or path is invalid!'; }

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json($json_dir);

my $projects = $api->cloud->projects;
print STDERR "Choosing first project\n";
my $project = $projects->[0] if scalar @$projects;
print STDERR $project->id."\n";


my $flavors = $project->flavors;
print STDERR "Picking random flavor\n";
my $flavor_count = scalar @$flavors;
my $flavor = $flavors->[int(rand $flavor_count)];
print STDERR $flavor->{id}."\n";

my $images = $project->images;
print STDERR "Picking random image\n";
my $image_count = scalar @$images;
my $image = $images->[int(rand $image_count)];

my $regions = $project->regions;
print STDERR "Choosing first region\n";
my $region = $regions->[0];
print STDERR $region."\n";

my $ssh_keys = $project->ssh_keys($region);
print STDERR "Picking random key\n";
my $key_count = scalar @$ssh_keys;
my $ssh_key = $ssh_keys->[int(rand $key_count)];
print STDERR $ssh_key->id."\n";

# Creating a new instance
my $instance = $project->create_instance(flavor_id => $flavor->{id}, image_id => $image->id, name => "Test-Instance", region => $region, ssh_key_id => $ssh_key->id);
$instance->delete;

# Getting available Networks for the choosen project
my $private_networks = $project->network->privates;
my $first_network = $private_networks->[0];
my $found_network = $project->network->private($first_network->id);

my $subnets = $found_network->subnets;
# Creating a new network in all regions
# region can be specified through region => xxxx parameter 
my $new_network = $project->network->create_private( name => "Test Network 1", vlan_id => 2 );
# Creating a new subnet
my $new_subnet = $new_network->create_subnet(dhcp => 'false', end => '192.168.1.24', start => '192.168.1.12)', no_gateway => 'false', region => $region, network => '192.168.1.0/24' );
# Cleaning up
$new_subnet->delete;
$new_network->delete;
