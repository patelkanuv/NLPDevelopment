#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Geo::IP;
use lib qw(../);
use Travel::Database::DBConfig;
my $gi = Geo::IP->open("/usr/share/GeoIP/GeoLiteCity.dat", GEOIP_STANDARD);


my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();

my ($match, $mismatch)= (0,0);

for(my $page = 100; $page <= 100; $page++) {
    my @location_list = get_locations($page);
    for(my $i = 0; $i < scalar(@location_list); $i++) {
        eval {                
            #call the tracking initiating method
            thread_action($location_list[$i]);
        };
    }
    print "Round ", $page, " match ", $match, " mismatch ", $mismatch, "\n";
} 



sub thread_action {
    my ($rec) = (@_);
    print "Maxmind DB ", $rec->startIpNum, ", ", $rec->endIpNum, "\n";    
    my $ipmean  = int(($rec->startIpNum + $rec->endIpNum) / 2);
    my ( $latitude, $longitude, $country_code ) = get_range_from_ip($ipmean);
    print "Maxmind OS pack ", $latitude, ", ", $longitude, "\n";
    
    my $airport = airport_by_distance($latitude, $longitude, $country_code);
    print $airport, ", ", $rec->airport_code,"\n";
}

sub get_locations {
    my $page = shift;
    my @rows = $schema->resultset('GeoIPBlocks')->search(undef,{ rows => 50000, page => $page, order_by => 'id'});    
    return @rows;
}

sub get_range_from_ip {
    my $decimal_ip  = shift;
    my $record = $gi->record_by_addr(dec2ip($decimal_ip));
    print Dumper dec2ip($decimal_ip);    
    print Dumper $record;
    return ($record->latitude, $record->longitude, $record->country_code);
}
sub ip2dec {
    unpack N => pack CCCC => split /\./ => shift;
}

sub dec2ip {
    join '.', unpack 'C4', pack 'N', shift;
}

sub airport_by_distance {
    my ( $latitude, $longitude, $country_code ) = @_;
    my @arr = (500, 1000, 1500, 2000, 2500, 3000);
    
    foreach my $distance (@arr) {
        my $airport = get_airportcode_from_location_id( $latitude, $longitude, $country_code, $distance );
        return $airport if defined $airport;
    }
    return undef;
}

sub get_airportcode_from_location_id {
    my ( $latitude, $longitude, $country_code, $distance1 ) = @_;

    ( $latitude, $longitude ) = get_latitude_longitude( $latitude, $longitude );
    
    my $distance = '(SQRT( (POWER('
        .$latitude
        .'-(latitude*3.14/180), 2)+POWER(('
        .$longitude
        .'-(longitude*3.14/180))*COS('
        .$latitude
        .'+(latitude*3.14/180)/2), 2))))*6371';
                    
    my @airports  = $schema->resultset('City')->search({
        $distance               => { '<' => $distance1},
        'LOWER(country_code)'   => lc($country_code),
        'operating'             => 'true'
    });
    
    return if(!scalar(@airports));
     
    my @airport = sort { 
                            $a->distance($latitude, $longitude) <=> $b->distance($latitude, $longitude)                       
                       } @airports;
    
    
    return $airport[0]->airport_code if defined $airport[0]->airport_code;
}

sub get_latitude_longitude {
    my ( $latitude, $longitude ) = @_;  
   
    $latitude  = $latitude  * 3.14 / 180;
    $longitude = $longitude * 3.14 / 180;
    
    return  $latitude, $longitude;
}
