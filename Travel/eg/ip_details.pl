use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Cache::DataCenter;

my $ip_details  = Travel::Cache::DataCenter->new();

my $airport = $ip_details->get_nearest_airport('113.20.16.148');
$airport    = $ip_details->get_nearest_airport('113.20.16.149');
$airport    = $ip_details->get_nearest_airport('113.20.16.138');
print $airport->[0]->city_name, " - ", $airport->[0]->airport_code,"\n";