use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Cache::DataCenter;
use Travel::IPList::GeoLocation;

my $ip = '74.118.100.2';
my $cache  = Travel::Cache::DataCenter->new();

my $airport = $cache->get_nearest_airport($ip);
print $airport->[0]->city_name, " - ", $airport->[0]->airport_code,"\n";

my $geo_location = Travel::IPList::GeoLocation->new('IP' => $ip);
print Dumper $geo_location->geo_record();