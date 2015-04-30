#!/usr/bin/perl

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);

my $key = 'Json user';
print "\n", md5_hex($key), "\n";
