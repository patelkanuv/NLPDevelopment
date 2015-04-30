#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Data::IPDetails;

my $ip_details  = Travel::Data::IPDetails->new( IP => '41.41.56.164');

print $ip_details->convert_ip_to_integer; #690567332
