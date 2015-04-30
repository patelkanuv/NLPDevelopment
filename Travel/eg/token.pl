use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Search::Token;

my $token1  = Travel::Search::Token->new( data => 'London');
print Dumper $token1;

my $token2  = Travel::Search::Token->new( data => 'Feb 27', position => 2);
print Dumper $token2;

my $token3  = Travel::Search::Token->new( data => 'cheap', position => 3);
print Dumper $token3;
