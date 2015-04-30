#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Cache::DataCenter;

my $cache_mngr  = Travel::Cache::DataCenter->new();

print Dumper $cache_mngr;
$cache_mngr->manager->store_cache('ID-1', { Name => 'Smita Patel', Class => 'BE 2008'});
print Dumper $cache_mngr->manager->read_cache('ID-1');
