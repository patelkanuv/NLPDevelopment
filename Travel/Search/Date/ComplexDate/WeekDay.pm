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

package Travel::Search::Date::ComplexDate::WeekDay;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../../);
use Travel::Data::Config qw(weekday_to_number);

has 'travel_dates'  => (is => 'rw', isa => 'ArrayRef[HashRef]');
has 'date_counter'  => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'expected_count'=> (is => 'rw', isa => 'Int', default => sub { 2 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

with 'Travel::Search::Date::Basic';

sub parse_travel_dates_around_day_name {
    my ($self)  = @_;
    
    $self->weekday_next_week();
    $self->next_weekday();
    $self->next_week();
    $self->next_weekend();
    $self->tomorrow();
    $self->today();
    
    return $self->travel_dates;
}

sub weekday_next_week {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day($self->tokens->get_tokens_byClass('DayName')) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($day);
            $next_token2    = $self->tokens->get_unused_next_token($next_token1);
            
            if($next_token1->data eq 'next' && $next_token2->data eq 'week') {
                $new_date1  = $self->get_next_week_weekday($day->data);
            }
            elsif($next_token1->data eq 'next' && $next_token2->data eq 'weekend') {
                $new_date1  = $self->get_next_week_weekday($day->data);
            }
            else {
                next;
            }
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                if($day->parsed_as eq 'Date'){
                    $self->mark_as_used_date([$next_token1, $next_token2]);
                }
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub next_weekday {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day($self->tokens->get_tokens_byClass('DayName')) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_prev_token($day);
            
            if($next_token1->data eq 'next') {
                $new_date1  = $self->get_next_weekday($day->data);
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

sub next_week {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('next')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($day);
            
            if($next_token1->data eq 'week') {
                if($self->tokens->get_two_prev_token_data($day) eq 'end of') {
                    $new_date1  = $self->get_next_week_weekday('saturday');
                    $self->tokens->mark_two_prev_token_data($day, 'Date');
                }
                else {
                    $new_date1  = $self->get_next_weekday('monday');
                }
                
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
            print STDERR $_;
            next;
        };
    }
    
    return ;
}

sub next_weekend {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('next')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $next_token1    = $self->tokens->get_unused_next_token($day);
            
            if($next_token1->data eq 'weekend') {
                $new_date1  = $self->get_next_weekday('saturday');
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

sub tomorrow {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('tomorrow')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $new_date1  = $self->get_date_from_sentence('tomorrow');
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                last;
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub today {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $day(@{$self->tokens->get_tokens_byData('today')}) {
        next if $day->is_used;
        my($next_token1, $next_token2, $new_date1);
        try {
            $new_date1  = $self->get_date_from_sentence('today');
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $day);
                last;
            }
        }
        catch{
            next;
        };
    }
    
    return ;
}

sub get_next_week_weekday {
    my ($self, $day)    = @_;
    
    my @next_week   = split(/\//x, $self->get_next_weekday('monday'));
    my $diff        = weekday_to_number($day) - 1;
    
    return sprintf("%04d/%02d/%02d", Add_Delta_Days($next_week[0], $next_week[1], $next_week[2],$diff));
}

1;

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut