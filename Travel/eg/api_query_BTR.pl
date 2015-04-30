#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use HTTP::Request;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use JSON qw( decode_json );

my $url = 'http://localhost:3000/';
my $ua  = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;

my @trip_type   = ('', 'OneWay', 'Round Trip');
my @trip_class  = ('', 'Economy', 'Business Class', 'First Class');
my @pax         = (
    '',
    '1 adult',
    '1 adult, 1 child',
    '1 adt, 2 child, 1 infant',
    '2 kids',
    'my parents',
    'my friends',
    '2 people',
);

my @dept_dates  = (
    '',
    '22/06/2013',
    '6/8/2013',
    '25/8',
    '9/22',
    '2013-5-15',
    '13th May',
    'next monday',
    'next week',
    'tomorrow',
    'last friday of june'
);

my @ret_dates  = (
    '',
    '25/06/2013',
    '6/14/2013',
    '28/8',
    '9/25',
    '2013-5-18',
    'after 10 days',
    'after 10 to 15 days',
    'October 15',
    '2nd week of august'
);

my @dept_airports   = (
    '',
    'YYC',
    'las vegas',
    'toronto',
    'london, lhr',
    'USA',
    'DE',
    'Ontario',
    'DC',
    'Spain'
);

my @ret_airports   = (
    'Vancouver',
    'bostn',
    'LAS',
    'Santiago',
    'Spain',
    'GB',
    'Alberta',
    'MB',
);

my $cnt = 1;
foreach my $dep (@dept_airports) {
    foreach my $ret (@ret_airports) {        
        foreach my $class (@trip_class){            
            foreach my $type (@trip_type){                
                foreach my $p   (@pax) {                        
                    DDATE:
                    foreach my $dd  (@dept_dates) {                        
                        if($type ne 'OneWay') {
                            RDATE:
                            foreach my $rd  (@ret_dates) {
                                my $sentance    = 'Want a flight '.$dep;
                                $sentance   .= ' to '.$ret;
                                $sentance   .= ' in best '.$class;
                                $sentance   .= ' '.$type .' journey ';
                                $sentance   .= ' for '.$p;
                                $sentance   .= ' depart on '.$dd;                                
                                $sentance   .= ' return '.$rd;
                                $cnt++;
                                if($cnt > 47970 ) {
                                    print $cnt, ") ", $sentance, "\n";
                                    #get_response($sentance);
                                }
                            }
                        } 
                        else {
                            my $sentance    = 'Want a flight '.$dep;
                            $sentance   .= ' to '.$ret;
                            $sentance   .= ' in best '.$class;
                            $sentance   .= ' '.$type .' journey ';
                            $sentance   .= ' for '.$p;
                            $sentance   .= ' depart on '.$dd;                                
                            $cnt++;
                            if($cnt > 47970 ) {
                                print $cnt, ") ", $sentance, "\n";
                                #get_response($sentance);
                            }
                        }    
                    }
                }
            }
        }
    }
}

sub get_response {
    my ($string)    = @_;
    
    my $params  = {
        'ip'            => '113.20.16.231',
        'client_key'    => 'f9d869cda22b431d4058097109e841bf',
         "search_text"  => $string,
    };
      
    my $request     = POST $url.'air/service/search', $params, Referer => $url;
    my $response    = $ua->request($request);
    if ($response->is_success) {
        my $decoded_json = decode_json( $response->decoded_content );
        print "Success :- ", $decoded_json->{ 'result' }{ 'success' };
        if($decoded_json->{ 'result' }{ 'success' } eq 'true') {
            print ", From :- ", $decoded_json->{ 'result' }{ 'query' }{ 'from_airport' }->[0]->{'airport_code'};
            print ", to :- ", $decoded_json->{ 'result' }{ 'query' }{ 'to_airport' }->[0]->{'airport_code'};
            print ", depart on :- ", $decoded_json->{ 'result' }{ 'query' }{ 'depart_date' };
            print ", return on :- ", $decoded_json->{ 'result' }{ 'query' }{ 'return_date' };
            print ", Pax :- ", $decoded_json->{ 'result' }{ 'query' }{ 'adult' };
            print ", ", $decoded_json->{ 'result' }{ 'query' }{ 'child' };
            print ", ", $decoded_json->{ 'result' }{ 'query' }{ 'infant' },"\n";
        }
        else {
            print "\nErrors :- ", Dumper $decoded_json->{ 'result' }{ 'errors' };
        }        
        print "\n";
    }
    else {
        print "Failed to Parse :- ", $string, "\n";
        exit(0);
    }
    
}
