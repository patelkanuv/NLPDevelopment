use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Database::CityData;

my $citydata    = Travel::Database::CityData->new;


my $all_airports = $citydata->match_city_info('new york'); 
foreach my $airport (@{$all_airports}) {
    print $airport->city_name, " - ", $airport->country_name, " - ",$airport->airport_code, "\n";
}
print "\nCity and Country matching\n";
$all_airports = $citydata->match_city_and_country_info('london', 'canada'); 

foreach my $airport (@{$all_airports}) {
    print $airport->city_name, " - ", $airport->country_name, " - ",$airport->airport_code, "\n";
}
