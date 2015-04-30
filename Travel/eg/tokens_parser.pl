#!/usr/bin/perl

use strict;
use warnings;

use Benchmark;
use Data::Dumper;
use lib qw(../../);
use Travel::Air::Search::Tokens::Parser;
use Travel::Air::Search::Validate;

#my $t0  = Benchmark->new;
my $token1  = Travel::Air::Search::Tokens::Parser->new(
                data_str    => 'ney yerk to spain in 2nd half April',
                'IP'        => '113.20.16.231'
            );

my $first   = $token1->parse_input;
print Dumper ($token1->tokens);

#my $t1  = Benchmark->new;
#my $td  = timediff($t1, $t0);
#print "the code took:",timestr($td),"\n";
    
#print Dumper $token1;
printf("%14s %s\n","Trip Type :",$token1->trip_type);
printf("%14s %s\n","Trip class :",$token1->trip_class);
printf("%14s %s\n","Depart Date :",$token1->depart_date);
printf("%14s %s\n","Return Date :",$token1->return_date);
printf("%14s %s\n","Adult :",$token1->pax_adult);
printf("%14s %s\n","Child :",$token1->pax_child);
printf("%14s %s\n","Infant :",$token1->pax_infant);

if(ref($token1->depart_airport) eq 'ARRAY') {
    foreach my $dep (@{$token1->depart_airport}) {
        if(ref($token1->return_airport) eq 'ARRAY') {
            foreach my $ret (@{$token1->return_airport}) {
                print $dep->city_name,", ", $dep->airport_code, " - ";
                print $ret->city_name,", ", $ret->airport_code, "\n";
            }    
        }
    }
}

#my $t2  = Benchmark->new;
#my $td1 = timediff($t2, $t0);
#print "the code took:",timestr($td1),"\n";

my $res = Travel::Air::Search::Validate->new(   parsed_data => $token1);
#print Dumper $res->apply_validations;
