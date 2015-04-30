######
##
## Copyright (c) PerlCraft.net, 2013
## The contents of this file are the property of PerlCraft.net or its
## associate companies or organizations (the Owners), and constitute
## copyrighted proprietary software and/or information.  This file or the
## information contained therein may not be used except in compliance
## with the terms set forth hereunder.
##
## Reproduction or distribution of this file or of the information
## contained therein in any form or through any mechanism whatsoever,
## whether electronic or otherwise, is prohibited except for lawful use
## within the organization by authorized employees of the Owners
##  for the purpose of software development or operational deployment
## on authorized equipment.  Removal of this file or its contents by any
## means whether electronic or physical save when expressly permitted in
## writing by the Owners or their authorized representatives is prohibited.
##
## Installation or copying of this file or of the code contained therein on
## any equipment excepting that owned or expressly authorized for the purpose
## by the Owners is prohibited.
##
## Any violation of the terms of this licence shall be deemed to be a
## violation of the Owner's intellectual property rights and shall be
## treated as such under the applicable laws and statutes.
##
######

=head1 AUTHOR

Kanu Patel, India
Email : patelkanuv@gmail.com

=cut

package Travel::Search::Date::Parser;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use feature qw(switch);
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../);
use Travel::Search::Date::ComplexDate::Parser;

has 'travel_dates'  => (is => 'rw', isa => 'ArrayRef[HashRef]');
has 'dep_date'      => (is => 'rw', isa => 'Str');
has 'date_counter'  => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'expected_count'=> (is => 'rw', isa => 'Int', default => sub { 2 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

with 'Travel::Search::Date::Basic';

sub parse_travel_dates {
    my ($self)  = @_;
    
    foreach my $token (@{$self->tokens->get_tokens_data_with_number}) {
        last if $self->date_counter >= $self->expected_count;
        $self->apply_date_match($token);
    }
    
    if($self->expected_count != $self->date_counter) {
        my $date_parser = Travel::Search::Date::ComplexDate::Parser->new(
                            tokens          => $self->tokens,
                            expected_count  => $self->get_expected_date_count
                        );
        my $travel_dates    = $date_parser->parse_complex_travel_dates();
        foreach my $date (@{$travel_dates}){
            last if $self->expected_count == $self->date_counter;
            $self->date_counter($self->date_counter + 1);
            my $dates       = $self->travel_dates;
            push(@{$dates}, $date);
            $self->travel_dates($dates);
        }
    }
    
    if($self->expected_count != $self->date_counter) {
        foreach my $token (@{$self->tokens->get_tokens_data_with_number}) {
            last if $self->date_counter >= $self->expected_count;
            next if $token->is_used;
            $self->apply_incomplete_date($token);
        }
    }
    
    if($self->expected_count != $self->date_counter && $self->date_counter == 1) {
        $self->apply_duration_based_dates;
    }
    elsif($self->expected_count == 2 && $self->date_counter == 0){
        $self->apply_approx_duration_based_dates;
    }
    
    #If only one date exist, check for return keyword to swap
    if($self->expected_count == 2 and $self->date_counter == 2) {
        $self->apply_date_swap_check();
    }
    
    return $self->travel_dates;
}

sub apply_date_match {
    my ($self, $token)   = @_;
    
    my $date    = $token->data;
    given($date) {
        when(/^\d{4}(-|\.|\/)\d{1,2}(-|\.|\/)\d{1,2}$/x)  {
            $self->validate_date($date, $token);
            return;
        };
        when(/^\d{1,2}(-|\.|\/)\d{1,2}(-|\.|\/)\d{4}$/x) {
            my @dates   = split(/-|\/|\./x, $date);
    
            if($dates[0] > 12) {
                my $new_date    = sprintf("%04d/%02d/%02d", $dates[2], $dates[1], $dates[0]);
                $self->validate_date($new_date, $token);
            }
            else {
                my $new_date    = sprintf("%04d/%02d/%02d", $dates[2], $dates[0], $dates[1]);
                $self->validate_date($new_date, $token);
            }
            return;
        };
    }
    return ;
}

sub apply_incomplete_date {
    my ($self, $token)   = @_;
    
    my $date    = $token->data;
    given($date) {
        when(/^\d{4}(-|\.|\/)\d{1,2}$/x) {
            my @dates   = split(/-|\/|\./x, $date);
            my $day     = $self->autocomplete_day_in_date($dates[0], $dates[1]);
            my $new_date    = sprintf("%04d/%02d/%02d", $dates[0], $dates[1], $day);
            $self->validate_date($new_date, $token);
            return;
        };
        when(/^\d{1,2}(-|\.|\/)\d{4}$/x) {
            my @dates   = split(/-|\/|\./x, $date);
            my $day     = $self->autocomplete_day_in_date($dates[1], $dates[0]);
            my $new_date    = sprintf("%04d/%02d/%02d", $dates[1], $dates[0], $day);
            $self->validate_date($new_date, $token);
            return;
        };
        when(/^\d{1,2}(-|\.|\/)\d{1,2}$/x) {
            my @dates   = split(/-|\/|\./x, $date);
    
            if($dates[0] > 12) {
                my $year        = $self->autocomplete_year_in_date($dates[1]);
                my $new_date    = sprintf("%04d/%02d/%02d", $year, $dates[1], $dates[0]);
                $self->validate_date($new_date, $token);
            }
            else {
                my $year        = $self->autocomplete_year_in_date($dates[0]);
                my $new_date    = sprintf("%04d/%02d/%02d", $year, $dates[0], $dates[1]);
                $self->validate_date($new_date, $token);
            }
            return;
        };
    }
    return;
}

sub apply_duration_based_dates {
    my($self)    = @_;
    
    my $dates   = $self->travel_dates;
    $self->dep_date($dates->[0]->{ 'date' });
    
    $self->find_week_based_duration;
    $self->find_weeks_based_duration;
    $self->find_dd_to_dd_day_based_duration;
    $self->find_dd_to_dd_days_based_duration;
    $self->find_day_based_duration;
    $self->find_days_based_duration;
    $self->return_on_following_weekday;
    
    return;
}

sub apply_approx_duration_based_dates {
    my($self)    = @_;
    
    my @date    = Today();
    my $date1   = sprintf( "%04d/%02d/%02d",
                        Add_Delta_Days(
                              $date[0],
                              $date[1],
                              $date[2],
                              15
                            )
                        );
    $self->dep_date($date1);
    
    $self->find_week_based_duration;
    $self->find_weeks_based_duration;
    $self->find_dd_to_dd_day_based_duration;
    $self->find_dd_to_dd_days_based_duration;
    $self->find_day_based_duration;
    $self->find_days_based_duration;
    if($self->date_counter == 1) {
        my $date_data   = {
            'date'      => $date1,
            'position'  => 0
        };
        my $pdates  = $self->travel_dates;
        my @dates   = ($date_data, $pdates->[0]);
        $self->travel_dates(\@dates);
    }
    
    return;
}

sub find_week_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('week')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            my @date    = split(/\//x, $self->dep_date);
            if($next_token1->has_number) {
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $next_token1->data * 7
                                    )
                            );
            }
            else {
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            7
                                    )
                            );
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub find_weeks_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('weeks')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            my @date    = split(/\//x, $self->dep_date);
            if($next_token1->has_number) {
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $next_token1->data * 7
                                    )
                            );
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub find_dd_to_dd_day_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('day')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $next_token3, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            $next_token2    = $self->tokens->get_unused_prev_token($next_token1);
            $next_token3    = $self->tokens->get_unused_prev_token($next_token2);
            
            my @date    = split(/\//x, $self->dep_date);
            if($next_token1->has_number && $next_token3->has_number
            && ($next_token2->data eq 'to' || $next_token2->data eq 'and')) {
                my $mean_day= int(($next_token1->data + $next_token3->data) / 2);
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $mean_day
                                    )
                            );
            }
            else {
               next;
            }
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1, $next_token2, $next_token3]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub find_dd_to_dd_days_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('days')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $next_token3, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            $next_token2    = $self->tokens->get_unused_prev_token($next_token1);
            $next_token3    = $self->tokens->get_unused_prev_token($next_token2);
            
            if($next_token1->has_number && $next_token3->has_number
            && ($next_token2->data eq 'to' || $next_token2->data eq 'and')) {
                my $mean_day= int(($next_token1->data + $next_token3->data) / 2);
                my @date    = split(/\//x, $self->dep_date);
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $mean_day
                                    )
                            );
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1, $next_token2, $next_token3]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub find_day_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('day')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            my @date    = split(/\//x, $self->dep_date);
            if($next_token1->has_number) {
                
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $next_token1->data
                                    )
                            );
            }
            else {
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            1
                                    )
                            );
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub find_days_based_duration {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('days')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            if($next_token1->has_number) {
                my @date    = split(/\//x, $self->dep_date);
                $new_date1  = sprintf("%04d/%02d/%02d",
                                      Add_Delta_Days(
                                            $date[0],
                                            $date[1],
                                            $date[2],
                                            $next_token1->data
                                    )
                            );
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1]);
                    last;
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub return_on_following_weekday {
    my($self)    = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('following')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($day);
            if($next_token1->class eq 'DayName') {
                $new_date1  = $self->get_next_weekday($next_token1->data, $self->dep_date);
            }
            else {
                next;
            }
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1]);
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}
        
sub apply_date_swap_check {
    my($self)    = @_;
    
    my $words_in_order  =  $self->are_keywords_in_order;
    my $dates_in_order  =  $self->are_dates_in_order;

    if($words_in_order != -1){
        if(!$words_in_order){
            $self->swap_travel_dates();
        }
    }
    elsif(!$dates_in_order) {
        $self->swap_travel_dates();
    }
    
    return ;
}


sub swap_travel_dates {
    my($self)    = @_;
    
    my @travel_dates    = @{$self->travel_dates};
    my @dates;
    push(@dates, $travel_dates[1]);
    push(@dates, $travel_dates[0]);
    $self->travel_dates(\@dates);
    
    return;
}

sub are_dates_in_order {
    my($self)    = @_;
    
    my @travel_dates    = @{$self->travel_dates};
    my @dep_date        = split(/\//x, $travel_dates[0]->{ 'date' });
    my @ret_date        = split(/\//x, $travel_dates[1]->{ 'date' });
    
    my $dd  = Delta_Days(
                    $dep_date[0], $dep_date[1], $dep_date[2],
                    $ret_date[0], $ret_date[1], $ret_date[2]
                );
    if($dd > 0){
        return 1;
    }
    
    return 0;
}

sub are_keywords_in_order {
    my($self)    = @_;
    
    my ($dep_pos, $ret_pos) = $self->get_date_keyword_position();
    my @travel_dates        = @{$self->travel_dates};
    
    if($dep_pos > 0 && $ret_pos > 0 ){
        if($dep_pos < $travel_dates[0]->{ 'position' } && $ret_pos < $travel_dates[1]->{ 'position' }){
            return 1;
        }
        return 0;
    }
    elsif($dep_pos > 0) {
        if($dep_pos < $travel_dates[0]->{ 'position' } ){
            return 1;
        }
        return 0;
    }
    elsif($ret_pos > 0) {
        if($ret_pos < $travel_dates[1]->{ 'position' } && $ret_pos > $travel_dates[0]->{ 'position' }){
            return 1;
        }
        return 0;
    }
    else {
        return -1; #Keywords not found
    }
}

sub get_date_keyword_position {
    my($self)    = @_;

    my($dep_position, $ret_position)    = (0, 0);
    foreach my $date (@{$self->travel_dates}) {
        my $token   = $self->tokens->get_token_byPosition($date->{ 'position' });
        try {
            my $prev_to_prev_token;
            my $prev_token  = $self->tokens->get_prev_token($token);
            try {
                foreach my $data (qw/on date/){
                    if($prev_token->date eq $data) {
                        $prev_to_prev_token  = $self->tokens->get_prev_token($prev_token);
                    }
                }
            };
            foreach my $tok ($prev_token, $prev_to_prev_token){
                next if(ref($tok) ne 'Travel::Search::Token');
                if ($self->check_depart_key($tok->data)) {
                    $dep_position   = $tok->position;
                }
                #print Dumper $self->check_return_key($tok->data);
                if ($self->check_return_key($tok->data)) {
                    $ret_position   = $tok->position;
                }
            }
        }
        catch {
            #Not a valid token
        };
    }

    return ($dep_position, $ret_position);
}

sub check_depart_key {
    my($self, $data)    = @_;
    
    given ($data){
        when(/departs/x||/depart/x||/departing/x||/departure/x) {
            return 1;
        };
        when(/depart_date/x||/depart-date/x||/departure_date/x) {
            return 1;
        };
    };

    return 0;
}

sub check_return_key {
    my($self, $data)    = @_;
    
    given ($data){
        when(/returns/||/return/||/returning/) {
            return 1;
        };
        when(/return_date/x||/return-date/x) {
            return 1;
        };
    };

    return 0;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;