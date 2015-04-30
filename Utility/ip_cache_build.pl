#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use bignum;
use Data::Dumper;
use Text::Unaccent; 

use lib qw(../);
use Travel::Database::DBConfig;
use Travel::Database::CityData;
use Travel::IPList::NorthAmerica::Store;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();
my $city_data   = Travel::Database::CityData->new();
my $cache_mngr  = Travel::IPList::NorthAmerica::Store->new();

#$schema->storage->debug(1);

my $count   = $ARGV[0];
#1..392724

print $count," ---> ", "\n";

for (my $cnt = $count; $cnt <= $count; $cnt++) {
    #next if $cnt < 22011;        
    my @rows = $schema->resultset('GeoIPBlocks')->search({
        location_id => $cnt
    });

    foreach my $row ( @rows ) {
        if(length($row->airport_code)) {
            #my $airport_data    = $city_data->match_by_airport_code($row->airport_code);
            #print $cnt, " - ", $row->startIpNum,", ", $row->endIpNum,", ", $row->airport_code,"\n";
            for my $x (range_local($row->startIpNum, $row->endIpNum)) {
                my $ip  = dec2ip($x);
                $cache_mngr->insert($ip, $row->airport_code);
                print $cnt, " - ", $x, " - ", dec2ip($x), ", ", $row->airport_code,"\n";
            }
        }
        
    }
}


sub dec2ip {
    join '.', unpack 'C4', pack 'N', shift;
}

sub ip2dec {
    unpack N => pack CCCC => split /\./ => shift;
}

sub range_local {
  my( $start, $end ) = @_;
  my @ret;
  while($start <= $end ){
    push @ret, $start;
    $start++;
  }
  return @ret;
}
