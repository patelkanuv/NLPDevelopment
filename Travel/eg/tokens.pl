use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Search::Tokens;

my $token1  = Travel::Search::Tokens->new( data_str => 'cheap flights vancouver mauritania to London departing third February monday');
print Dumper $token1;
my $first   = $token1->get_first_token;
my $last    = $token1->get_last_token;


#print Dumper $token1->get_prev_token($last);
#print Dumper $token1->get_next_token($last);

#print Dumper $token1->get_prev_token($first);
#print Dumper $token1->get_next_token($first);

#print Dumper $token1->get_regular_token;
