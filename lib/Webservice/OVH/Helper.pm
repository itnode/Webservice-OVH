package Webservice::OVH::Helper;

use strict;
use warnings;
use Carp qw{ carp croak };

use DateTime::Format::Strptime;

sub construct_filter {

    my ( $class, %params ) = @_;

    my @params = keys %params;
    my @values = values %params;
    my $filter = scalar @values ? '?' : "";

    foreach my $param (@params) {

        my $value = $params{$param};
        next unless $value;

        $value = $value eq '_empty_' ? "" : $value;

        if ( $filter ne '?' ) {

            $filter .= '&';
        }

        $filter .= sprintf( "%s=%s", $param, $value );
    }

    return $filter;
}

sub parse_datetime {

    my ( $class, $str_datetime, $locale, $timezone ) = @_;

    my $strp = DateTime::Format::Strptime->new(
        pattern   => '%FT%T',
        locale    => ( $locale || 'de_DE' ),
        time_zone => ( $timezone || 'Europe/Berlin' ),
        on_error  => 'croak',
    );

    return $strp->parse_datetime($str_datetime);
}

1;
