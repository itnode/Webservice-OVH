use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 5;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");

my $example_email_domains = $api->email->domain->domains;
my $example_email_domain = $example_email_domains->[0];

ok ( ref $example_email_domains eq 'ARRAY', "eample domains ok");
ok ( $api->email->domain->domain_exists($example_email_domain->name), "example domain exists ok" );

my $domain = $api->email->domain->domain($example_email_domain->name);
ok( $domain, "getting single domain ok" );

my $no_domain = $api->email->domain->domain("FOR SURE NO DOMAIN");
ok ( !$no_domain, "getting no domain ok");

ok( scalar @$example_email_domains == scalar @{ $api->email->domain->{_aviable_domains} }, "compare with intern list ok" );

done_testing();