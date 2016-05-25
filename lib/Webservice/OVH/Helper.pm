package Webservice::OVH::Helper;

sub construct_filter {
    
    my ($class, %params) = @_;
    
    my @params = keys %params;
    my @values = values %params;
    my $filter = scalar @values ? '?' : "";
    
    foreach my $param ( @params ) {
        
        my $value = $params{$param};
        next unless $value;
        
        $value = $value eq '_empty_' ? "" : $value;
        
        if( $filter ne '?') {
            
            $filter.= '&';
        }
        
        $filter .= sprintf("%s=%s", $param, $value);
    }
    
    return $filter;
}


1;