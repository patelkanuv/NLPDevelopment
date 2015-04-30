#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Date::Calc qw( Today Localtime );    
use IPC::System::Simple qw( systemx );
use MongoDB;

use lib qw(../);
use Travel::Database::DBConfig;

use constant NO_THREADS => 4;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();

my $client  = MongoDB::MongoClient->new(host => 'localhost:27017');
my $db      = $client->get_database( 'IptoAirport' );
my $ipblockstoairport   = $db->get_collection( 'ipblockstoairport' );

my $counter = 1;
#1 to 392724

for(my $page = 1; $page <= 126; $page++) {
    my @location_list = get_locations($page);
    for(my $i = 0; $i < scalar(@location_list); $i++) {
        eval {                
            #call the tracking initiating method
            thread_action($location_list[$i]);
        };
    }
}    
my ($year,$month,$day, $hour,$min,$sec, $doy,$dow,$dst) = Localtime();
print "\nEnd time :- $year","-",$month,"-",$day," $hour:$min:$sec";
    
#call the search action 
sub thread_action {
    my ($rec) = (@_);
    print $rec->id, ", ", $rec->startIpNum, ", ", $rec->endIpNum, ", ", $rec->location_id->location_id, "\n";
    $ipblockstoairport->insert({
        "id"            => $rec->id,
        "airport_code"  => $rec->airport_code,
        "startipnum"    => int($rec->startIpNum),
        "endipnum"      => int($rec->endIpNum),
        "location_id"   => $rec->location_id->location_id
    });
}

sub get_locations {
    my $page = shift;
    my @rows = $schema->resultset('GeoIPBlocks')->search(undef,{ rows => 50000, page => $page, order_by => 'id'});    
    return @rows;
}
