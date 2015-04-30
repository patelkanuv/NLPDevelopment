use strict;
use warnings;

use Data::Dumper;
use lib qw(..);
use Travel::IPList::NorthAmerica::Store;

my $cache_mngr  = Travel::IPList::NorthAmerica::Store->new();

for(range_local(1138155890,1138155895)) {
    my $ip  = decimal_to_ip($_);
    print $ip, " --> ", $cache_mngr->select($ip),"\n";
}

sub decimal_to_ip {
    join '.', unpack 'C4', pack 'N', shift;
}

sub ip_to_decimal {
    unpack N => pack CCCC => split /\./ => shift;
}

sub range_local {
  my( $start, $end ) = @_;
  my @ret;
  while($start <= $end ){
    push @ret, $start;
    $start++;
  }
  return @ret;
}
