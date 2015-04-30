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

package Travel::Search::Date::ComplexDate::Month;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use Date::Manip::Date;
use Date::Calc qw(Today Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../../);
use Travel::Data::Config qw(month_to_number);

has 'travel_dates'  => (is => 'rw', isa => 'ArrayRef[HashRef]');
has 'date_counter'  => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'expected_count'=> (is => 'rw', isa => 'Int', default => sub { 2 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

with 'Travel::Search::Date::Basic';

sub parse_travel_dates_around_month_name {
    my ($self)  = @_;
    
    #Month Sanity Check
    $self->check_manth_and_month;
    
    $self->check_month_dd_dd();
    $self->check_dd_dd_month();
    $self->check_month_dd_and_dd();
    $self->check_month_dd_to_dd();
    $self->check_dd_to_dd_month();
    $self->check_month_dd_yyyy();
    $self->check_dd_month_yyyy();
    $self->check_week_of_month();
    $self->check_weekend_of_month_dd();
    $self->check_weekend_of_month();
    $self->check_month_week();
    $self->check_month_weekend_of_dd();
    $self->check_month_weekend();
    $self->check_weekday_of_month();
    $self->check_half_of_month();
    $self->check_dd_month();
    $self->check_month_dd();
    $self->check_month_year();
    $self->check_inferance_date();
    
    return $self->travel_dates;
}

sub check_manth_and_month {
     my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token1, $next_token2 );
        try {
            $next_token1    = $self->tokens->get_unused_next_token($month);
            $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            
            if($next_token1->data eq 'and' && $next_token2->class eq 'MonthName') {
                $next_token2->token_parsed_as('Extra');
            }
        }
        catch {
            print STDERR $_;
            next;
        }
    }
    
    return;
}

sub check_month_dd_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token, $next_to_next_token, $dd1, $dd2);
        try {
            $next_token = $self->tokens->get_unused_next_token($month);
            $next_to_next_token = $self->tokens->get_unused_next_token($next_token);
            
            next if !$next_token->has_number;
                        
            if($next_token->data =~ /-/x){
                my @dates   = split(/-/x, $next_token->data);
                $dd1 = $dates[0];
                $dd2 = $dates[1];
            }
            else {
                next if !$next_to_next_token->has_number;
                $dd1 = $self->extract_date($next_token->data);
                $dd2 = $self->extract_date($next_to_next_token->data);
            }
            my $mon = month_to_number($month->data);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            my $new_date2   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd2
                            );
            if( $self->is_valid_date($new_date1) && $self->is_valid_date($new_date2)) {
                $self->validate_date($new_date1, $month);
                $self->validate_date($new_date2, $month);
                if($month->parsed_as eq 'Date'){
                    if($next_token->data =~ /-/x){
                        $self->mark_as_used_date([$next_token]);
                    }
                    else {
                        $self->mark_as_used_date([$next_token, $next_to_next_token]);
                    }
                }
            }
        }
        catch {
            print STDERR  $_;
            next;
        };
    }
    
    return;
}

sub check_month_dd_and_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token, $next_to_next_token, $next_token_2, $dd1, $dd2);
        try {
            $next_token         = $self->tokens->get_unused_next_token($month);
            $next_token_2       = $self->tokens->get_unused_next_token($next_token);
            $next_to_next_token = $self->tokens->get_unused_next_token($next_token_2);
            
            next if !$next_token->has_number;
            next if $next_token_2->data ne 'and';
            next if !$next_to_next_token->has_number;

            $dd1 = $self->extract_date($next_token->data);
            $dd2 = $self->extract_date($next_to_next_token->data);

            my $mon = month_to_number($month->data);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      ($dd1 + $dd2) / 2
                            );
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token, $next_token_2, $next_to_next_token]);
                }
            }
        }
        catch {
            print STDERR  $_;
            next;
        };
    }
    
    return;
}


sub check_month_dd_to_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token, $next_to_next_token, $next_token_2, $dd1, $dd2);
        try {
            $next_token         = $self->tokens->get_unused_next_token($month);
            $next_token_2       = $self->tokens->get_unused_next_token($next_token);
            $next_to_next_token = $self->tokens->get_unused_next_token($next_token_2);
            
            next if !$next_token->has_number;
            next if $next_token_2->data ne 'to';
            next if !$next_to_next_token->has_number;
            
            $dd1 = $self->extract_date($next_token->data);
            $dd2 = $self->extract_date($next_to_next_token->data);

            my $mon = month_to_number($month->data);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            my $new_date2   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd2
                            );
            if( $self->is_valid_date($new_date1) && $self->is_valid_date($new_date2)) {
                $self->validate_date($new_date1, $month);
                $self->validate_date($new_date2, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token, $next_token_2, $next_to_next_token]);
                }
            }
        }
        catch {
            print STDERR  $_;
            next;
        };
    }
    
    return;
}

sub check_dd_dd_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token, $prev_to_prev_token, $dd1, $dd2);
        try {
            $prev_token = $self->tokens->get_unused_prev_token($month);
            $prev_to_prev_token = $self->tokens->get_unused_prev_token($prev_token);
            
            next if !$prev_token->has_number;
            if($prev_token->data =~ /-/x){
                my @dates   = split(/-/x, $prev_token->data);
                $dd1 = $dates[0];
                $dd2 = $dates[1];
            }
            else {
                next if !$prev_to_prev_token->has_number;
                $dd1 = $self->extract_date($prev_to_prev_token->data);
                $dd2 = $self->extract_date($prev_token->data);
            }
            my $mon = month_to_number($month->data);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            my $new_date2   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd2
                            );
            if( $self->is_valid_date($new_date1) && $self->is_valid_date($new_date2)) {
                $self->validate_date($new_date1, $month);
                $self->validate_date($new_date2, $month);
                if($month->parsed_as eq 'Date'){
                    if($prev_token->data =~ /-/x){
                        $self->mark_as_used_date([$prev_token]);
                    }
                    else {
                        $self->mark_as_used_date([$prev_token, $prev_to_prev_token]);
                    }
                }
            }
            
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_dd_to_dd_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token, $prev_to_prev_token, $prev_token_2, $dd1, $dd2);
        try {
            $prev_token         = $self->tokens->get_unused_prev_token($month);
            $prev_token_2       = $self->tokens->get_unused_prev_token($prev_token);
            $prev_to_prev_token = $self->tokens->get_unused_prev_token($prev_token_2);
            
            next if !$prev_token->has_number;
            next if $prev_token_2->data ne 'to';
            next if !$prev_to_prev_token->has_number;
            
            $dd1 = $self->extract_date($prev_to_prev_token->data);
            $dd2 = $self->extract_date($prev_token->data);

            my $mon = month_to_number($month->data);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            my $new_date2   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd2
                            );
            if( $self->is_valid_date($new_date1) && $self->is_valid_date($new_date2)) {
                $self->validate_date($new_date1, $month);
                $self->validate_date($new_date2, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$prev_token, $prev_token_2, $prev_to_prev_token]);
                }
            }
            
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_month_dd_yyyy {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token, $next_to_next_token);
        try {
            $next_token = $self->tokens->get_unused_next_token($month);
            $next_to_next_token = $self->tokens->get_unused_next_token($next_token);

            next if !$next_token->has_number;
            next if !$next_to_next_token->has_number;
            
            my $dd  = $self->extract_date($next_token->data);
            my $new_date    = sprintf("%04d/%02d/%02d",
                                      $next_to_next_token->data,
                                      month_to_number($month->data),
                                      $dd
                            );
            $self->validate_date($new_date, $month);
            if($month->parsed_as eq 'Date'){
                $self->mark_as_used_date([$next_token, $next_to_next_token]);
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_dd_month_yyyy {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')){
        next if $month->is_used;
        my($next_token, $prev_token);
        try {
            $next_token = $self->tokens->get_unused_next_token($month);
            $prev_token = $self->tokens->get_unused_prev_token($month);
        
            next if !$next_token->has_number;
            next if !$prev_token->has_number;
            
            my $dd  = $self->extract_date($prev_token->data);
            my $new_date    = sprintf("%04d/%02d/%02d",
                                      $next_token->data,
                                      month_to_number($month->data),
                                      $dd
                            );
            $self->validate_date($new_date, $month);
        }
        catch{
            next;
        };
        
        if($month->parsed_as eq 'Date'){
            $self->mark_as_used_date([$next_token, $prev_token]);
        }
    }
    
    return ;
}

sub check_month_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token, $dd1);
        try {
            $next_token = $self->tokens->get_unused_next_token($month);
            next if !$next_token->has_number;
            
            $dd1 = $self->extract_date($next_token->data);
            my $mon = month_to_number($month->data, $dd1);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token]);
                }
            }
        }
        catch {
            print STDERR  $_;
            next;
        };
    }
    
    return;
}

sub check_dd_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token, $dd1);
        try {
            $prev_token = $self->tokens->get_unused_prev_token($month);
            next if !$prev_token->has_number;
            $dd1 = $self->extract_date($prev_token->data);
            my $mon = month_to_number($month->data, $dd1);
            my $year= $self->autocomplete_year_in_date($mon, $dd1);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd1
                            );
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$prev_token]);
                }
            }
            
        }
        catch {
            next;
        };
    }
    
    return;
}


sub check_week_of_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token1, $prev_token2, $prev_token3, $dd);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($month);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            
            try {
                $prev_token3    = $self->tokens->get_unused_prev_token($prev_token2);
            };
            my $mon = month_to_number($month->data);
            my @parsed_tokens   = ($prev_token1);
            if($prev_token1->data eq 'of' && $prev_token2->data eq 'week') {
                $dd = $self->get_date_from_token($prev_token3, $mon);
                push(@parsed_tokens, $prev_token3) if($prev_token3->data =~ /$dd/x);
                push(@parsed_tokens, $prev_token2);
            }
            elsif($prev_token1->data eq 'week') {
                $dd = $self->get_date_from_token($prev_token2, $mon);
                push(@parsed_tokens, $prev_token2) if($prev_token2->data =~ /$dd/x);
            }
            else {
                next;
            }
            
            my $year= $self->autocomplete_year_in_date($mon, $dd);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd
                            );
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@parsed_tokens);
                }
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_weekend_of_month_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token1, $prev_token2, $new_date1, $next_token1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($month);
            $prev_token1    = $self->tokens->get_unused_prev_token($month);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            
            next if !$next_token1->has_number;
            my @parsed_tokens   = ($prev_token1);
            
            if($prev_token1->data eq 'of' && $prev_token2->data eq 'weekend') {
                my $dd1 = $self->extract_date($next_token1->data);
                my $mon = month_to_number($month->data, $dd1);
                my $year= $self->autocomplete_year_in_date($mon, $dd1);
                
                $new_date1   = sprintf("%04d/%02d/%02d",
                                          $year,
                                          $mon,
                                          $dd1);
                $new_date1   = $self->get_nearest_weekend($new_date1);
            }
            else {
                next;
            }
            
            push(@parsed_tokens, $next_token1, $prev_token2);
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@parsed_tokens);
                }
            }
        }
        catch {
            print STDERR $_;
            next;
        };
    }
    
    return;
}

sub check_weekend_of_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token1, $prev_token2, $prev_token3, $new_date1);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($month);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            
            try {
                $prev_token3    = $self->tokens->get_unused_prev_token($prev_token2);
            };
            my @parsed_tokens   = ($prev_token1);
            my $position        = $self->get_week_from_token($prev_token3);
            
            if($prev_token1->data eq 'of' && $prev_token2->data eq 'weekend') {
                $new_date1  = $self->get_date_from_sentence($position.' saturday of '.$month->data);
                push(@parsed_tokens, $prev_token3) if($prev_token3->data =~ /$position/x);
                push(@parsed_tokens, $prev_token2);
            }
            elsif($prev_token1->data eq 'weekend') {
                $position       = $self->get_week_from_token($prev_token2);
                $new_date1  = $self->get_date_from_sentence($position.' saturday of '.$month->data);
                push(@parsed_tokens, $prev_token2) if($prev_token2->data =~ /$position/x);
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@parsed_tokens);
                }
            }
        }
        catch {
            print STDERR $_;
            next;
        };
    }
    
    return;
}

sub check_month_week {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token1, $next_token2, $dd);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($month);
            $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            
            my $mon = month_to_number($month->data);
            if($next_token2->data eq 'week') {
                $dd = $self->get_date_from_token($next_token1, $mon);
            }
            elsif($next_token1->data eq 'week') {
                $dd = 1;
            }
            else {
                next;
            }
            my $year= $self->autocomplete_year_in_date($mon, $dd);
            
            my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd
                            );
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    if($next_token2->data eq 'week') {
                        $self->mark_as_used_date([$next_token1, $next_token2]);
                    }
                    elsif($next_token1->data eq 'week') {
                        $self->mark_as_used_date([$next_token1]);
                    }
                }
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_month_weekend_of_dd {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token1, $next_token2, $next_token3, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($month);
            $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            $next_token3    = $self->tokens->get_unused_next_token($next_token2);
            
            next if !$next_token3->has_number;
            
            if($next_token1->data eq 'weekend' && $next_token2->data eq 'of') {
                my $dd1 = $self->extract_date($next_token3->data);
                my $mon = month_to_number($month->data, $dd1);
                my $year= $self->autocomplete_year_in_date($mon, $dd1);
                
                $new_date1   = sprintf("%04d/%02d/%02d",
                                          $year,
                                          $mon,
                                          $dd1);
                $new_date1   = $self->get_nearest_weekend($new_date1);
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1, $next_token2, $next_token3]);
                }
            }
        }
        catch{
            print STDERR $_;
            next;
        };
    }
    
    return;
}

sub check_month_weekend {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($month);
            $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            my $position    = $self->get_week_from_token($next_token1);
            if($next_token2->data eq 'weekend') {
                $new_date1  = $self->get_date_from_sentence($position.' saturday of '.$month->data);
            }
            elsif($next_token1->data eq 'weekend') {
                $new_date1  = $self->get_date_from_sentence('1st saturday of '.$month->data);
            }
            else {
                next;
            }

            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    if($next_token2->data eq 'weekend') {
                        $self->mark_as_used_date([$next_token1, $next_token2]);
                    }
                    elsif($next_token1->data eq 'weekend') {
                        $self->mark_as_used_date([$next_token1]);
                    }
                }
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_weekday_of_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;

    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token1, $prev_token2, $prev_token3, $new_date1);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($month);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            
            try {
                $prev_token3    = $self->tokens->get_unused_prev_token($prev_token2);
            };
            
            my $position        = $self->get_week_from_token($prev_token3);
            my @parsed_tokens   = ($prev_token1);
            if($prev_token1->data eq 'of' && $prev_token2->class eq 'DayName') {
                $new_date1  = $self->get_date_from_sentence($position.' '.$prev_token2->data.' of '.$month->data);
                push(@parsed_tokens, $prev_token3) if($prev_token3->data =~ /$position/x);
                push(@parsed_tokens, $prev_token2);
            }
            elsif($prev_token1->class eq 'DayName') {
                $position       = $self->get_week_from_token($prev_token2, 1);
                $new_date1  = $self->get_date_from_sentence($position.' '.$prev_token1->data.' of '.$month->data);
                push(@parsed_tokens, $prev_token2) if($prev_token2->data =~ /$position/x);
            }
            else {
                next;
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@parsed_tokens);
                }
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_half_of_month {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;

    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($prev_token1, $prev_token2, $prev_token3, $new_date1, $dd, $mon, $year);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($month);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            
            try {
                $prev_token3    = $self->tokens->get_unused_prev_token($prev_token2);
            };
            my @parsed_tokens   = ($prev_token1);
            if($prev_token1->data eq 'of' && $prev_token2->data eq 'half') {
                $dd    = $self->get_date_from_month_half($prev_token3);
                push(@parsed_tokens, $prev_token3) if($prev_token3->data eq '1st' or $prev_token3->data eq '2nd');
                push(@parsed_tokens, $prev_token2);
            }
            elsif($prev_token1->data eq 'half') {
                $dd    = $self->get_date_from_month_half($prev_token2);
                push(@parsed_tokens, $prev_token2) if($prev_token2->data eq '1st' or $prev_token2->data eq '2nd');
            }
            else {
                next;
            }
            $mon = month_to_number($month->data);
            $year= $self->autocomplete_year_in_date($mon, $dd);
            
            $new_date1   = sprintf("%04d/%02d/%02d",
                                      $year,
                                      $mon,
                                      $dd
                            );
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
                if($month->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@parsed_tokens);
                }
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_month_year {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $month($self->tokens->get_tokens_byClass('MonthName')) {
        next if $month->is_used;
        my($next_token1, $next_token2, $dd, $mon, $year);
        $mon    = month_to_number($month->data);
        $dd     = $self->autocomplete_day_in_date(undef, $mon);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($month);
            
            if($next_token1->data eq 'early'){
                $dd = 4;
            }
            elsif($next_token1->data eq 'mid' || $next_token1->data eq 'middle'){
                $dd = 15;
            }
            elsif($next_token1->data eq 'late' || $next_token1->data eq 'end'){
                $dd = 25;
            }
            elsif($next_token1->data eq 'of'){
                $next_token2    = $self->tokens->get_unused_prev_token($next_token1);
                if($next_token2->data eq 'end') {
                    $dd = 25;
                }
                elsif($next_token2->data eq 'middle') {
                    $dd = 15;
                }
            }
        };
        try {
            $year           = $self->autocomplete_year_in_date($mon, $dd);
            my $new_date1   = sprintf("%04d/%02d/%02d", $year, $mon, $dd);
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $month);
            }
        }
        catch {
            next;
        };
    }
    
    return;
}

sub check_inferance_date {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    return if $self->date_counter   == 0;
    
    my $dates   = $self->travel_dates;
    foreach my $data (qw/return returning/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            my ($next_token1, $next_token2);
            try {
                $next_token1    = $self->tokens->get_unused_next_token($token);
                $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            
                next if !$next_token2->has_number;
                
                if ($next_token1 ->data eq 'on' || $next_token1 ->data eq 'the') {
                    my $dd = $self->extract_date($next_token2->data);
                    my @parts   = split(/\/|-/x, $dates->[0]->{ 'date' });
                    my $new_date1   = sprintf("%04d/%02d/%02d",
                                      $parts[0],
                                      $parts[1],
                                      $dd
                            );
            
                    if( $self->is_valid_date($new_date1)) {
                        $self->validate_date($new_date1, $next_token2);
                        if($next_token2->parsed_as eq 'Date'){
                            $self->mark_as_used_date([$token, $next_token2]);
                        }
                    }
                }
            }
            catch {
                next;
            };
            
        }
    }
    
    return;
}

sub extract_date {
    my ($self, $dd)  = @_;
    
    my ($day)   = $dd =~/^(\d{1,2})(st|nd|rd|th)?$/x;
    return $day;
}

sub get_date_from_token {
    my ($self, $token, $mon)  = @_;
    
    my $date    = 1;
    return $date if ref($token) ne 'Travel::Search::Token';
    
    if($token->data eq 'last') {
        if($mon == 2) {
            return 22;
        }
        return 29;
    }
    
    return $date if !($token->has_number);
    my ($dd)  = $token->data =~ /^(\d+)/x;
    
    if($dd >= 1 && $dd <= 4){
        given($dd) {
            when("1") {
                return 1;
            };
            when("2"){
                return 8;
            };
            when("3"){
                return 15;
            };
            when("4"){
                return 22;
            };
            when("5"){
                return 29;
            };
        };
    }
    
    return $date;
}


sub get_date_from_month_half {
    my ($self, $token)  = @_;
    
    my $date    = 1;
    return $date if ref($token) ne 'Travel::Search::Token';
    
    if($token->data eq 'last') {
        return 15;
    }
    
    return $date if !($token->has_number);
    my ($dd)  = $token->data =~ /^(\d+)/x;
    
    if($dd >= 1 && $dd <= 4){
        given($dd) {
            when("1") {
                return 1;
            };
            when("2"){
                return 15;
            };
        };
    }
    
    return $date;
}


sub get_week_from_token {
    my ($self, $token)  = @_;

    my $date    = '1st';
    return $date if ref($token) ne 'Travel::Search::Token';
    
    if($token->data eq 'last') {
        return 'last';
    }
    
    return $date if !($token->has_number);
    
    if($token->data =~ /^(\d+)(st|nd|rd|th)/x){
        return $token->data;
    }
    
    return $date;
}
1;
=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut