#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 30;

use lib qw(../../);

BEGIN {
    use_ok( 'Travel::Air::Search::Tokens::Parser' );
    use_ok( 'Travel::Air::Search::Validate' );
};

#Step 1
my $token1  = Travel::Air::Search::Tokens::Parser->new(
                data_str    => 'I want to visit new york for a weekend in winter',
                'IP'        => '113.20.16.231'
            );
$token1->parse_input;

#step 2
my $result  = Travel::Air::Search::Validate->new( parsed_data => $token1 );
my $final   = $result->apply_validations;

isa_ok($token1, 'Travel::Air::Search::Tokens::Parser');
isa_ok($result, 'Travel::Air::Search::Validate');

cmp_ok(ref($token1->depart_airport), 'eq', 'ARRAY', 'from_airport_check');
cmp_ok(scalar(@{$token1->depart_airport}), '==', 1, 'from_airport_check');

cmp_ok($token1->depart_airport->[0]->airport_code, 'eq', 'AMD', '0_from_airport_code_check');

cmp_ok(ref($token1->return_airport), 'eq', 'ARRAY', 'to_airport_check');
cmp_ok(scalar(@{$token1->return_airport}), '==', 3, 'to_airport_check');

cmp_ok($token1->return_airport->[0]->airport_code, 'eq', 'LGA', '0_to_airport_code_check');

cmp_ok($token1->trip_class, 'eq', 'Economy', 'trip_class_check');
cmp_ok($token1->trip_type, 'eq', 'RoundTrip', 'trip_type_check');

#cmp_ok($token1->depart_date, 'eq', '2013/03/30', 'depart_date_check');
cmp_ok($token1->return_date, 'eq', 'Default', 'return_date_check');

cmp_ok($token1->pax_adult, '==', 1, 'adult_check');
cmp_ok($token1->pax_child, '==', 0, 'child_check');
cmp_ok($token1->pax_infant, '==', 0, 'infant_check');

cmp_ok($final->{ 'success' }, 'eq', 'true', 'query_status');

#Step 2 result check
my $query   = $final->{ 'query' };
isa_ok($query, 'Travel::Air::Search::Query');

cmp_ok(ref($query->from_airport), 'eq', 'ARRAY', 'from_airport_check');
cmp_ok(scalar(@{$query->from_airport}), '==', 1, 'from_airport_check');

cmp_ok($query->from_airport->[0]->airport_code, 'eq', 'AMD', '0_from_airport_code_check');

cmp_ok(ref($query->to_airport), 'eq', 'ARRAY', 'to_airport_check');
cmp_ok(scalar(@{$query->to_airport}), '==', 3, 'to_airport_check');

cmp_ok($query->to_airport->[0]->airport_code, 'eq', 'LGA', '0_to_airport_code_check');

cmp_ok($query->trip_class, 'eq', 'Economy', 'trip_class_check');
cmp_ok($query->trip_type, 'eq', 'RoundTrip', 'trip_type_check');

#cmp_ok($query->depart_date, 'eq', '2013/03/30', 'depart_date_check');
cmp_ok($query->return_date, 'eq', '2013/12/10', 'return_date_check');

cmp_ok($query->adult, '==', 1, 'adult_check');
cmp_ok($query->child, '==', 0, 'child_check');
cmp_ok($query->infant, '==', 0, 'infant_check');
