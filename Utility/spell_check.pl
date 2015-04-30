#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(../);
use General::SpellCheck::Simple;
use Travel::Database::DBConfig;

#add City Names to Dictionary
my $check   = General::SpellCheck::Simple->new();
print Dumper $check->suggestions('alberta');
