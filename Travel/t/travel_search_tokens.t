#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Test::More tests => 34;

use lib qw(../../);

BEGIN {
    use_ok( 'General::SpellCheck::Simple' );
    use_ok( 'Travel::Search::Token' );
    use_ok( 'Travel::Search::Tokens' );
    use_ok( 'Travel::Data::Replacer',
            qw(
                replace_country_name
                replace_search_abbreviations
                replace_month_strings
                spelling_check
            )
    );
    
    use_ok( 'Travel::Data::Dictionary',
            qw(
                is_this_word_start_of_cityname 
                is_this_word_calendar_abbreviation 
                is_this_word_three_letter_verb
            )
    );
};

my $tokens  = Travel::Search::Tokens->new( data_str => 'Ahmedabad to Prague any Friday return 2 to 5 days later' );
isa_ok($tokens, 'Travel::Search::Tokens');

cmp_ok($tokens->data_str, 'eq', 'Ahmedabad to Prague any Friday return 2 to 5 days later', 'data_check');
cmp_ok($tokens->token_count, 'eq', '11', 'tokens_check');

my @tokens_obj  = @{$tokens->tokens};

cmp_ok($tokens_obj[0]->data, 'eq', 'ahmedabad', '0_position_token_check');
cmp_ok($tokens_obj[1]->data, 'eq', 'to',        '1_position_token_check');
cmp_ok($tokens_obj[2]->data, 'eq', 'prague',    '2_position_token_check');
cmp_ok($tokens_obj[3]->data, 'eq', 'any',       '3_position_token_check');
cmp_ok($tokens_obj[4]->data, 'eq', 'friday',    '4_position_token_check');
cmp_ok($tokens_obj[5]->data, 'eq', 'return',    '5_position_token_check');
cmp_ok($tokens_obj[6]->data, 'eq', '2',         '6_position_token_check');
cmp_ok($tokens_obj[7]->data, 'eq', 'to',        '7_position_token_check');
cmp_ok($tokens_obj[8]->data, 'eq', '5',         '8_position_token_check');
cmp_ok($tokens_obj[9]->data, 'eq', 'days',      '9_position_token_check');
cmp_ok($tokens_obj[10]->data, 'eq', 'later',    '10_position_token_check');

my $token   = $tokens->get_first_token();
cmp_ok($token->data, 'eq', 'ahmedabad', 'get_first_token');

my $last_token   = $tokens->get_last_token();
cmp_ok($last_token->data, 'eq', 'later', 'get_last_token');

my $next    = $tokens->get_next_token($token);
cmp_ok($next->data, 'eq', 'to', 'get_next_token');

$next       = $tokens->get_next_token($last_token);
cmp_ok(ref($next), 'eq', '', 'get_next_token');

my $prev    = $tokens->get_prev_token($token);
cmp_ok(ref($prev), 'eq', '', 'get_prev_token');

$prev       = $tokens->get_prev_token($last_token);
cmp_ok($prev->data, 'eq', 'days', 'get_prev_token');

my $toks    = $tokens->get_regular_token();
cmp_ok(scalar(@$toks), '==', 6, 'get_regular_token');

cmp_ok($toks->[0]->data, 'eq', 'ahmedabad', '0_position_token_check');
cmp_ok($toks->[5]->data, 'eq', 'later',     '5_position_token_check');

$toks    = $tokens->get_tokens_byData('to');
cmp_ok($toks->[0]->position, 'eq', '2', '0_position_token_check');
cmp_ok($toks->[1]->position, 'eq', '8',     '5_position_token_check');

my @toks    = $tokens->get_tokens_byClass('DayName');
cmp_ok($toks[0]->position, 'eq', '5', '0_position_token_check');
cmp_ok($toks[0]->data, 'eq', 'friday', '0_position_token_check');

$toks    = $tokens->get_token_byPosition(5);
cmp_ok($toks->position, 'eq', '5', '0_position_token_check');
cmp_ok($toks->data, 'eq', 'friday', '0_position_token_check');
