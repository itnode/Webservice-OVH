use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";

use Test::More;

use Webservice::OVH;

my $api = Webservice::OVH->new_from_json("../credentials.json");
ok( $api, "module ok" );

my $contacts = $api->me->contacts;
my $contact = $contacts->[0];

ok ( $contact->properties && ref $contact->properties eq 'HASH', 'properties ok' );
ok ( $contact->address && ref $contact->address eq 'HASH', 'address ok');
ok ( $contact->birth_day && ref $contact->birth_day eq 'DateTime', 'birth_day ok');
ok ( $contact->email, 'email ok');
ok ( $contact->first_name, 'first_name ok');
ok ( $contact->language, 'language ok');
ok ( $contact->last_name, 'last_name ok');
ok ( $contact->legal_form, 'legal_form ok');

done_testing();