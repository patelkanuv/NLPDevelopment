#!/usr/bin/perl

use strict;
use warnings;
use Date::Calc qw( Today Localtime );    
use IPC::System::Simple qw( systemx );

use lib qw(../);
use Travel::Database::DBConfig;

use constant NO_THREADS => 4;

my $dbm         = Travel::Database::DBConfig->new;
my $schema      = $dbm->get_handle();

my $counter     = 1;
#1 to 392724
my @location_list = get_locations();

for(my $i = 1; $i <= scalar(@location_list); $i+= NO_THREADS) {
    my @childs;
    for (my $j = 0; $j < NO_THREADS; $j++) {
        print $counter++," / ", scalar(@location_list),"\n";
        my $pid = fork();
        if ($pid) {
            push(@childs, $pid);
        } 
        elsif ($pid == 0) {
            eval {
                local $SIG{ALRM} = sub {die "THREADTIMEOUT"; };
                alarm(3600);  # 30 sec max loop time
                #call the tracking initiating method
                thread_action($location_list[$i + $j]);
                CORE::exit(0);
            };
            if ($@ eq "THREADTIMEOUT") {
                print STDERR "Thread ".$$." timed out\n";
            } 
            else {
                die "$@" if $@;
            }
        } 
        else {
            die "couldnt fork: $!\n";
        }
    }
    foreach my $chpid (@childs) {
        waitpid($chpid,0);
    }
}
    
    my ($year,$month,$day, $hour,$min,$sec, $doy,$dow,$dst) = Localtime();
    print "\nEnd time :- $year","-",$month,"-",$day," $hour:$min:$sec";
    
#call the search action 
sub thread_action{
    systemx ("perl",'Utility/ip_cache_build.pl', @_);
}

sub get_locations {
    my @locations = $schema->resultset('GeoIPLocation')->search(
        {
            'country'    => 'CA',
            'location_id'=> { '>' => 15758}
        }
    );
    
    my @list;
    foreach my $location (@locations) {
        push(@list,$location->location_id);
    }
    
    return @list;
}
