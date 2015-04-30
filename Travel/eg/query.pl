#!/usr/bin/perl

use Moose;
use DateTime;
use lib qw(../../);
use Travel::Air::Search::Query;
use Travel::Data::Airport;

my $query   = Travel::Air::Search::Query->new(
    'from_airport'  => Travel::Data::Airport->new(
                        'city_name'         => 'Toronto',
                        'country_name'      => 'Canada',
                        'country_code'      => 'CA',
                        'airport_name'      => 'Pearson International',
                        'airport_code'      => 'YYZ',
                        'prov_state_name'   => 'ON',
                        'prov_state_code'   => 'ON'),
    'to_airport'    => Travel::Data::Airport->new(
                        'city_name'         => 'Vancouver',
                        'country_name'      => 'Canada',
                        'country_code'      => 'CA',
                        'airport_name'      => 'Vancouver International',
                        'airport_code'      => 'YVR',
                        'prov_state_name'   => 'BC',
                        'prov_state_code'   => 'BC'),
    'depart_date'   => DateTime->new( year => 2013, month => 05, day => 8),
    'return_date'   => DateTime->new( year => 2013, month => 05, day => 15),
    'adult'         => 2,
);

print $query->print_query; 
