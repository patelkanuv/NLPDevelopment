#!/usr/bin/perl

use strict;
use warnings;
 	
use IPC::System::Simple qw( systemx );

for(my $i = 1; $i <= 392724; $i+= 400) {
	my @childs;
	for (my $j = 0; $j < 399; $j+=100) {
	    
	    my $pid = fork();
	    if ($pid) {
		    push(@childs, $pid);
		} 
		elsif ($pid == 0) {
    		eval {
                local $SIG{ALRM} = sub {die "THREADTIMEOUT"; };
                alarm(1200);  # 30 sec max loop time
                #call the tracking initiating method
            	thread_action($i + $j);
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
	
#call the search action 
sub thread_action{
	systemx ("perl",'add_airport_code.pl', @_);
}
