#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use Data::Dumper;
use Text::Unaccent; 

use lib qw(../);
use Travel::Database::DBConfig;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();
#$schema->storage->debug(1);

my $count   = $ARGV[0];
#1..392724
for($count..$count+99) {  
    next if $_ > 392724;
    my @rows = $schema->resultset('GeoIPLocation')->search({
        location_id => $_
    });


    foreach my $row ( @rows ) {
        my $airport = airport_by_cityname( $row );
        if (!defined $airport) {
            $airport = airport_by_distance( $row );
        }

        if($airport) {
            my $rows1 = $schema->resultset('GeoIPBlocks')->search(
                { location_id => $row->location_id}
            );
            $rows1->update(
                { airport_code => $airport}
            );
            
            print $row->location_id, ", ", $row->city,", ", $row->country,", ", $airport,"\n";
        }
        
    }
}
sub airport_by_cityname {
    my ($row)   = @_;
    
    if(defined $row->city &&  $row->city ne '') {
        my @airports = $schema->resultset('City')->search({
            'LOWER(city_name)'      => lc($row->city),
            'LOWER(country_code)'   => lc($row->country),
            'operating'             => 'true'
        });        
        
        return if(!scalar(@airports));
        
        my $longitude   = $row->longitude;
        my $latitude    = $row->latitude;
        
        @airports = sort { $a->distance($latitude, $longitude) <=> $b->distance($latitude, $longitude)}
        @airports;
        
        my $airport;
        $airport = $airports[0]->airport_code if(defined $airports[0]);
        
        return $airport;
    }
        
    return ;
}

sub airport_by_distance {
    my ( $row ) = @_;
    my @arr = (500, 1000, 1500, 2000, 2500, 3000);
    
    foreach my $distance (@arr) {
        my $airport = get_airportcode_from_location_id( $row, $distance );
        return $airport if defined $airport;
    }
    return undef;
}

sub get_airportcode_from_location_id {
    my ( $geo_location, $distance1 ) = @_;

    my ( $latitude, $longitude ) = get_latitude_longitude( $geo_location );
    
    my $distance = '(SQRT( (POWER('
        .$latitude
        .'-(latitude*3.14/180), 2)+POWER(('
        .$longitude
        .'-(longitude*3.14/180))*COS('
        .$latitude
        .'+(latitude*3.14/180)/2), 2))))*6371';
                    
    my @airports  = $schema->resultset('City')->search({
        $distance               => { '<' => $distance1},
        'LOWER(country_code)'   => lc($geo_location->country),
        'operating'             => 'true'
    });
    
    return if(!scalar(@airports));
     
    my @airport = sort { $a->distance($latitude, $longitude) <=> $b->distance($latitude, $longitude)
    } @airports;
    
    
    return $airport[0]->airport_code if defined $airport[0]->airport_code;
}

sub get_latitude_longitude {
    my ( $geo_location ) = @_;  
   
    my $latitude  = $geo_location->latitude  * 3.14 / 180;
    my $longitude = $geo_location->longitude * 3.14 / 180;
    
    return  $latitude, $longitude;
}
