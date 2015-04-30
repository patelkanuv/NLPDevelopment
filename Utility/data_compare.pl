#!/usr/bin/perl

use strict;
use warnings;

use Try::Tiny;
use lib qw(../);
use Travel::Database::DBConfig;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();

foreach my $airport ($schema->resultset('Airport')->search({ airport_code => { 'IN' => ['XTA', 'TCZ', 'RLK', 'NAY', 'LZY']} }) ) {
    #next if !$airport->operating;
    print $airport->airport_code,"\n";
    #my @all_airports = $schema->resultset('Airport')->search(
    #    {   'LOWER(airport_code)'   => lc($airport->airport_code) }
    #);
    
    #if(scalar(@all_airports) == 0 ) {
        #print $airport->airport_code, "\n";
    #    next;
    #}
    #if($airport->country_code ne $all_airports[0]->country_code) {
    #    print $airport->airport_code, " - ", $airport->country_code, " - ", $all_airports[0]->country_code,"\n";
    #}
    my $new_airport = $schema->resultset('City')->create({
        'airport_code'  => $airport->airport_code,
        'airport_name'  => $airport->airport_name,
        'country_name'  => $airport->country_name,
        'country_code'  => $airport->country_code,
        'city_name'     => $airport->city,
        'longitude'     => $airport->longitude,
        'latitude'      => $airport->latitude 
    });
}
