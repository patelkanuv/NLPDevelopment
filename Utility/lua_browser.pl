#!/usr/bin/perl

use strict;
use warnings;
use HTTP::Request;
use HTTP::Request::Common qw(POST);
use Data::Dumper;
use Time::HiRes qw (tv_interval gettimeofday);
use LWP::UserAgent;
use HTML::TreeBuilder::XPath;
use Try::Tiny;

use lib qw(../);
use Travel::Database::DBConfig;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

#Airport Details
#http://www.world-airport-codes.com/search/?Submit=1&criteria=LGA&searchWhat=airportcode
for('a'..'z') {
    my $ac_url      = "http://www.world-airport-codes.com/alphabetical/country-name/".$_.".html";
    my $response    = $ua->get($ac_url);

    my %codes;
    my @heads       = ('country name', 'Image', 'airport name', 'country_code', 'World Area Code', 'airport_code');
    if ($response->is_success) {
        print $ac_url,"\n";
        my $tree    = HTML::TreeBuilder::XPath->new();
        $tree->parse_content($response->decoded_content);
        my $tables  = $tree->findnodes('//table[@class = "results"]');
        
        my @nodes   = $tables->[0]->findnodes('.//tr[@class = "one"]');
        push(@nodes, $tables->[0]->findnodes('.//tr[@class = "two"]'));
        foreach my $tr (@nodes) {
            my $cnt = 0;
            my %hash;
            foreach my $td ($tr->findnodes('.//td')){            
                $hash{ $heads[ $cnt++ ] } = $td->as_text;
            }
            
            my $wa_data;
            try {
                $wa_data = _get_more_info_from_world_airport($hash{ 'airport_code' });
            };
            catch {
                print "Failed world airport code ", $hash{ 'airport_code' },"\n";
            };
            my $fs_data = _get_data_from_flight_stats($hash{ 'airport_code' });
            
            try { 
                $hash{ 'Longitude' }    = $fs_data->{ 'Longitude' };
                $hash{ 'Latitude' }     = $fs_data->{ 'Latitude' }; 
                $hash{ 'City' }         = $wa_data->{ 'City' }; 
                $hash{ 'GMT Offset' }   = $wa_data->{ 'GMT Offset' };
                $hash{ 'Email' }        = $wa_data->{ 'Email' }; 
                #$hash{ 'Website' }      = $wa_data->{ 'Website' };
                $hash{ 'Telephone' }    = $wa_data->{ 'Telephone' }; 
                $hash{ 'Fax' }          = $wa_data->{ 'Fax' };
                $hash{ 'Runway Length' }= $wa_data->{ 'Runway Length' };
                $hash{ 'Runway Elevation' } = $wa_data->{ 'Runway Elevation' };            
            };
            #print Dumper \%hash;
            add_into_database(\%hash);
            #$codes{ $hash{ 'airport_code' } }    = \%hash;
        }
    }
    else {
        print $response->status_line;
        print "failed ", $ac_url, "\n";
    }
}

sub _get_more_info_from_world_airport {
    my($code)   = @_; 
   
    my $wa_url      = "http://www.world-airport-codes.com/search/?Submit=1&searchWhat=airportcode&criteria=".$code;
    my $response    = $ua->get($wa_url);

    if ($response->is_success) {
        my $tree    = HTML::TreeBuilder::XPath->new();
        $tree->parse_content($response->decoded_content);
        my @nodes   = $tree->findnodes('//div[@class = "airportdetails"]//div[@class = "column1"]');
        push(@nodes,  $tree->findnodes('//div[@class = "airportdetails"]//div[@class = "column2"]'));
        my @labels;
        my $cnt = 0;
        foreach my $node (@nodes){        
            foreach my $n ($node->findnodes('label')){
                $labels[ $cnt++ ] = $n->as_text;
            }
        }
        my @values;
        $cnt = 0;
        foreach my $node (@nodes){            
            foreach my $n ($node->findnodes('span')){
                my $str = $n->as_text;
                $str    =~ s/\(\?\)//g;
                $str    =~ s/://g;
                $str    =~ s/^\s+//g;
                $str    =~ s/\s+$//g;
                $values[ $cnt++ ] = $str;
            }
        }
        my %hash;
        for(0..15) {
            $hash{ $labels[ $_ ] } = $values[ $_ ];
        }
        
        return \%hash;
    }

}

sub _get_data_from_flight_stats {
    my ($code)  = @_;
    
    my $ll_url      = "http://www.flightstats.com/go/Airport/airportDetails.do?airportCode=".$code;
    my $response1   = $ua->get($ll_url);
    if ($response1->is_success) {
        my $tree1   = HTML::TreeBuilder::XPath->new();
        $tree1->parse_content($response1->decoded_content);
        my $div     = $tree1->findnodes('//div[@class = "airportOverviewDetailsColumn"]');
        my %hash;
        try {    
            my $string  = $div->[0]->as_text;
            my ($lat, $long)    = $string =~ /Longitude:\s(-?\d+\.\d+)\s\/\s(-?\d+\.\d+)/x;
            $hash{ 'Latitude' }     = $lat;
            $hash{ 'Longitude' }    = $long;
        };
        return \%hash;
    }
}

sub add_into_database {
    my ($data)  = @_;
    try {
        my $new_album = $schema->resultset('Airport')->create({
            airport_name    => $data->{ 'airport name' },
            country_name    => $data->{ 'country name' },
            country_code    => $data->{ 'country_code' },
            city            => $data->{ 'City' },
            airport_code    => $data->{ 'airport_code' },
            runway_length   => $data->{ 'Runway Length' },
            runway_elevation=> $data->{ 'Runway Elevation' },
            longitude       => $data->{ 'Longitude' },
            latitude        => $data->{ 'Latitude' },
            world_area_code => $data->{ 'World Area Code' },
            email           => $data->{ 'Email' },
            telephone       => $data->{ 'Telephone' },
            fax             => $data->{ 'Fax' },
            gmt_offset      => $data->{ 'GMT Offset' },
        });
    }
    catch {
        print $_,"\n";
    };
}
