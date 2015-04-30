#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 17;

use lib qw(../../);

BEGIN {
    use_ok( 'Travel::Search::Token' );
};

my $token1  = Travel::Search::Token->new( data => 'London');

isa_ok($token1, 'Travel::Search::Token');
cmp_ok($token1->data, 'eq', 'London', 'data_check');
cmp_ok($token1->class, 'eq', 'Regular', 'class_check');
cmp_ok($token1->has_number, '==', 0, 'number_check');
cmp_ok($token1->is_used, '==', 0, 'usage_check');
cmp_ok($token1->is_spell_correct, '==', 1, 'spell_check');
cmp_ok($token1->parsed_as, 'eq', 'None', 'parser_check');
$token1  = Travel::Search::Token->new( data => 'Londo');

isa_ok($token1, 'Travel::Search::Token');
cmp_ok($token1->data, 'eq', 'Londo', 'data_check');
cmp_ok($token1->class, 'eq', 'Regular', 'class_check');
cmp_ok($token1->has_number, '==', 0, 'number_check');
cmp_ok($token1->is_used, '==', 0, 'usage_check');
cmp_ok($token1->is_spell_correct, '==', 0, 'spell_check');
cmp_ok($token1->parsed_as, 'eq', 'None', 'parser_check');

$token1->mark_token_used;
cmp_ok($token1->is_used, '==', 1, 'usage_check');

$token1->mark_token_unused;
cmp_ok($token1->is_used, '==', 0, 'usage_check');