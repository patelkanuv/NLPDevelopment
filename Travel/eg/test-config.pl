use strict;
use warnings;

use Data::Dumper;

use lib qw(../../);
use Travel::ConfigLoader;

my $conf = Travel::ConfigLoader->new();

print Dumper $conf;
