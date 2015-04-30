#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 15;

BEGIN {
    use_ok( 'Cwd' );
    use_ok( 'Carp' );
    use_ok( 'Moose' );
    use_ok( 'Try::Tiny' );
    use_ok( 'DateTime' );
    use_ok( 'Benchmark' );
    use_ok( 'BerkeleyDB' );
    use_ok( 'Date::Calc' );
    #use_ok( 'Moose::Role' );
    use_ok( 'Data::Dumper' );
    use_ok( 'Lingua::Ispell' );
    use_ok( 'Config::General' );
    use_ok( 'Cache::Memcached' );
    use_ok( 'Date::Manip::Date' );
    use_ok( 'namespace::autoclean' );
    use_ok( 'Data::Structure::Util' );
};
