use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More tests => 9;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");

my $example_email_domains = $api->email->domain->domains;
my $example_email_domain = $example_email_domains->[0];

ok ($example_email_domain, "example domain ok");
ok ($example_email_domain->service_infos && ref $example_email_domain->service_infos eq 'HASH', "service_info ok");
ok ($example_email_domain->properties && ref $example_email_domain->properties eq 'HASH', "properties ok");
ok ($example_email_domain->properties && ref $example_email_domain->properties eq 'HASH', "properties ok");
ok (ref $example_email_domain->allowed_account_size eq 'ARRAY', "allowed_account_size ok");
ok (ref $example_email_domain->creation_date eq 'DateTime', "creation_date ok");
ok ($example_email_domain->status, "status ok");

my $redirections = $example_email_domain->redirections;
ok (ref $redirections eq 'ARRAY', "redirections ok");

if(scalar @$redirections ) {
    
    my $redirection = $redirections->[0];
    ok (ref $redirection  eq 'Webservice::OVH::Email::Domain::Domain::Redirection', "Type ok");
}

done_testing();


