#!/bin/sh

apt-get install ispell libdb-dev libberkeleydb-perl libdbd-pg-perl geoip-database libgeo-ip-perl

PERL_MM_USE_DEFAULT=1 cpan Cwd
PERL_MM_USE_DEFAULT=1 cpan Carp
PERL_MM_USE_DEFAULT=1 cpan Moose
PERL_MM_USE_DEFAULT=1 cpan DateTime
PERL_MM_USE_DEFAULT=1 cpan Try::Tiny
PERL_MM_USE_DEFAULT=1 cpan Benchmark
#PERL_MM_USE_DEFAULT=1 cpan BerkeleyDB
PERL_MM_USE_DEFAULT=1 cpan Date::Calc
PERL_MM_USE_DEFAULT=1 cpan Moose::Role
PERL_MM_USE_DEFAULT=1 cpan MooseX::Clone
PERL_MM_USE_DEFAULT=1 cpan Data::Dumper
PERL_MM_USE_DEFAULT=1 cpan Lingua::Ispell
PERL_MM_USE_DEFAULT=1 cpan Config::General
PERL_MM_USE_DEFAULT=1 cpan Cache::Memcached
PERL_MM_USE_DEFAULT=1 cpan Date::Manip::Date
PERL_MM_USE_DEFAULT=1 cpan namespace::autoclean
PERL_MM_USE_DEFAULT=1 cpan Data::Structure::Util
PERL_MM_USE_DEFAULT=1 cpan DBIx::Class

PERL_MM_USE_DEFAULT=1 cpan Catalyst::Devel
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Runtime
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Plugin::ConfigLoader
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Plugin::Static::Simple
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Action::RenderView
PERL_MM_USE_DEFAULT=1 cpan Catalyst::View::TT
PERL_MM_USE_DEFAULT=1 cpan JSON
PERL_MM_USE_DEFAULT=1 cpan Catalyst::View::JSON
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Plugin::Unicode
PERL_MM_USE_DEFAULT=1 cpan Catalyst::ScriptRunner
PERL_MM_USE_DEFAULT=1 cpan Moose
PERL_MM_USE_DEFAULT=1 cpan namespace::autoclean
PERL_MM_USE_DEFAULT=1 cpan Config::General
PERL_MM_USE_DEFAULT=1 cpan Test::More
PERL_MM_USE_DEFAULT=1 cpan Data::Validate::IP
PERL_MM_USE_DEFAULT=1 cpan Catalyst::Model::DBIC::Schema
PERL_MM_USE_DEFAULT=1 cpan MooseX::NonMoose

#wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz

