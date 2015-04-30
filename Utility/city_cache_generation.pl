#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(../);
use Travel::Database::DBConfig;
use Travel::Cache::DataCenter;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();
my $cache_mngr  = Travel::Cache::DataCenter->new();

##
generate_city_cache();

#Generate unique city names,
#produce all the city names for it
#store it in Cache
sub generate_city_cache {
    my @all_airports    = $schema->resultset('City')->search(
                            {},                                       
                            {
                                select  => [ { DISTINCT => 'city_name'} ],
                                as      => ['city_name'],
                            }
                        );
    
    foreach my $airport (@all_airports) {
        my $city_details    = $cache_mngr->match_by_city_name(lc($airport->city_name));
        $city_details       = $cache_mngr->match_by_airport_code(lc($airport->airport_code));
    }
    
    return;
}
