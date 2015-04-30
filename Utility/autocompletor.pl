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

my $airport_rs = $schema->resultset('City')->search({
    'country_code'  => 'CA' 
});

while (my $rs = $airport_rs->next) {
    _get_data_from_fn($rs);
}

sub _get_data_from_fn {
    my ($rs)  = @_;
    
    my $code    = $rs->airport_code;
    my $ll_url  = "http://www.flightnetwork.com/flights/utility?&limit=50&timestamp=1364012553547".
                  "&action_param=autocompleter&gateway_departure=".$code."&q=".$code;
    my $response1   = $ua->get($ll_url);
    if ($response1->is_success) {
        my @compo   = split(",", $response1->decoded_content());
        my $state   = $compo[1];
        $state      =~ s/\s+//gx;
        return if !defined $state;
        
        my $airport_rs  = $schema->resultset('ProvinceState')->search({
            'code'      => $state 
        });
        try {
            my $name    = $airport_rs->next->prov_name;
            print $code, " -> ", $state, " -> ", $name,  "\n";
            
            $rs->update({
                prov_name   => $name,
                prov_code   => $state,
            });
        }
        catch{
            print STDERR $code, " -> $_";
        };
        #exit(0);
    }
}

