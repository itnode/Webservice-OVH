use strict;
use warnings;
use DDP;
use List::Util qw(first);
use DateTime;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use lib "$Bin/../inc";
use Webservice::OVH;

sub load_csv {
    
    my ($file) = @_;
    
    my $domain_list = [];
    
    open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";

    while (my $row = <$fh>) {
        
        $row =~ s/\r\n//g;
        my @row = split(',', $row);
        my $object = { area => $row[0], domain => $row[1], status => $row[2], auth => $row[3] };
        push @$domain_list, $object;
    }
    
    close $fh;
    
    return $domain_list;
}

my $api = Webservice::OVH->new_from_json("../credentials.json");

my $domains = load_csv('domains.csv');

my $cart = $api->order->new_card;

foreach my $domain (@$domains) {
    
    if( $domain->{status} eq 'connect' && $domain->{auth} ) {
        
        my $offers = $cart->offers_domain($domain->{status});
        
        my @offer = grep { $_->{offer} eq 'gold' } @$offers;
        my $offer_id = $offer[0]->{offerId};
        my $orderable = $offer[0]->{orderable};
        
        $cart->add_domain( $domain->{domain}, offer_id => $offer_id, auth_info => $domain->{auth} );
    }
}

my $checkout = $cart->info_checkout;
p $checkout;
#my $order = $cart->checkout;
#$order->pay_with_registered_payment_mean('fidelityAccount');

$cart->delete;

=head2
foreach my $domain (@$domains) {
    
    if( $domain->{status} eq 'connect' && $domain->{auth} ) {
        
        my $order = $api->order->domain->zone->order($domain->{domain}, 'true');
        $order->pay_with_registered_payment_mean('fidelityAccount');
    }
}
=cut

