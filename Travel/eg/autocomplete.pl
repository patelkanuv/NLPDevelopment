use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Air::Search::AutoComplete;

my $auto    = Travel::Air::Search::AutoComplete->new( word1 => 'lon', word2 => 'lon', search_text => 'London LHR to Boston, BOS dep');
print Dumper $auto->get_suggestions;
