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

package Travel::Search::Date::ComplexDate::Season;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use Date::Calc qw(Today Delta_Days Add_Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../../);
use Travel::Data::Config qw(get_season_month);

has 'travel_dates'  => (is => 'rw', isa => 'ArrayRef[HashRef]');
has 'date_counter'  => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'expected_count'=> (is => 'rw', isa => 'Int', default => sub { 2 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

with 'Travel::Search::Date::Basic';

sub parse_travel_dates_around_season_name {
    my ($self)  = @_;
    
    $self->christmas_season();
    $self->halloween_season();
    $self->mid_season();
    $self->end_of_season();
    $self->season();
    
    return $self->travel_dates;
}

sub christmas_season {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $token (@{$self->tokens->get_tokens_byData('christmas')}) {
        next if $token->is_used;
        next if $self->expected_count == $self->date_counter;
        my $dd     = 25;
        my $mon    = 12;
        my $year   = $self->autocomplete_year_in_date($mon, $dd);

        my $new_date1  = sprintf("%04d/%02d/%02d",
                            $year,
                            $mon,
                            $dd
                        );
            
        if( $self->is_valid_date($new_date1)) {
            $self->validate_date($new_date1, $token);
            last;
        }
    }
    
    return;
}

sub halloween_season {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $token (@{$self->tokens->get_tokens_byData('halloween')}) {
        next if $token->is_used;
        next if $self->expected_count == $self->date_counter;
        my $dd     = 30;
        my $mon    = 10;
        my $year   = $self->autocomplete_year_in_date($mon, $dd);

        my $new_date1  = sprintf("%04d/%02d/%02d",
                            $year,
                            $mon,
                            $dd
                        );
            
        if( $self->is_valid_date($new_date1)) {
            $self->validate_date($new_date1, $token);
            last;
        }
    }
    
    return;
}

sub mid_season {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $season($self->tokens->get_tokens_byClass('Season')) {
        next if $season->is_used;
        next if $self->expected_count == $self->date_counter;
        my($prev_token1, $new_date1, $year, $mon, $dd);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($season);
            my @used_tokens = ($season);
            if($prev_token1->data eq 'mid') {
                $dd     = 1;
                $mon    = get_season_month($season->data, 'mid');
                $year   = $self->autocomplete_year_in_date($mon, $dd);
            }
            else {
                next;
            }
            push(@used_tokens, $prev_token1);
            $new_date1  = sprintf("%04d/%02d/%02d",
                            $year,
                            $mon,
                            $dd
                        );
            $new_date1  = $self->adjust_season_date($season->data, $new_date1, 'mid', 'mid');
            if(ref($self->tokens->get_token_byData('weekend')) eq 'Travel::Search::Token') {
                my $week_token  = $self->tokens->get_token_byData('weekend');
                push(@used_tokens, $week_token);
                $new_date1  = $self->get_next_weekday('saturday', $new_date1);
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $season);
                if($season->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@used_tokens);
                }
            }
        }
        catch {
            next;   
        };
    }
    
    return ;
}

sub end_of_season {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $season($self->tokens->get_tokens_byClass('Season')) {
        next if $season->is_used;
        next if $self->expected_count == $self->date_counter;
        my($prev_token1, $prev_token2, $prev_token3, $new_date1, $year, $mon, $dd);
        try {
            $prev_token1    = $self->tokens->get_unused_prev_token($season);
            $prev_token2    = $self->tokens->get_unused_prev_token($prev_token1);
            try {
                $prev_token3    = $self->tokens->get_unused_prev_token($prev_token2);
            };
            
            my @used_tokens;
            if($prev_token1->data eq 'this' && $prev_token2->data eq 'of' && $prev_token3->data eq 'end') {
                push(@used_tokens, ($prev_token1, $prev_token2, $prev_token3));
            }
            elsif($prev_token1->data eq 'of' && $prev_token2->data eq 'end') {
                push(@used_tokens, ($prev_token1, $prev_token2));
            }
            elsif($prev_token1->data eq 'end') {
                push(@used_tokens, $prev_token1);
            }
            else {
                next;
            }
            
            $dd     = 1;
            $mon    = get_season_month($season->data, 'end');
            $year   = $self->autocomplete_year_in_date($mon, $dd);
                
            $new_date1  = sprintf("%04d/%02d/%02d",
                            $year,
                            $mon,
                            $dd
                        );
            $new_date1  = $self->adjust_season_date($season->data, $new_date1, 'end');
            if(ref($self->tokens->get_token_byData('weekend')) eq 'Travel::Search::Token') {
                my $week_token  = $self->tokens->get_token_byData('weekend');
                push(@used_tokens, $week_token);
                $new_date1  = $self->get_next_weekday('saturday', $new_date1);
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $season);
                if($season->parsed_as eq 'Date'){
                    $self->mark_as_used_date(\@used_tokens);
                }
            }
        }
        catch {
            next;
        };
    }
    
    return ;
}

sub season {
    my ($self)  = @_;
    
    return if $self->expected_count == $self->date_counter;
    foreach my $season($self->tokens->get_tokens_byClass('Season')) {
        next if $season->is_used;
        next if $self->expected_count == $self->date_counter;
        my($prev_token1, $new_date1, $year, $mon, $dd);
        try {
            
            $dd     = 1;
            $mon    = get_season_month($season->data, 'start');
            $year   = $self->autocomplete_year_in_date($mon, $dd);
            
            $new_date1  = sprintf("%04d/%02d/%02d",
                            $year,
                            $mon,
                            $dd
                        );
            $new_date1  = $self->adjust_season_date($season->data, $new_date1);
            
            my @used_tokens = ($season);
            if(ref($self->tokens->get_token_byData('weekend')) eq 'Travel::Search::Token') {
                my $week_token  = $self->tokens->get_token_byData('weekend');
                push(@used_tokens, $week_token);
                $new_date1  = $self->get_next_weekday('saturday', $new_date1);
            }
            
            if( $self->is_valid_date($new_date1)) {
                $self->validate_date($new_date1, $season);
                $self->mark_as_used_date(\@used_tokens);
            }
        }
        catch {
            next;
        };
    }
    
    return ;
}

sub adjust_season_date {
    my ($self, $season, $new_date, $position1, $position2)  = @_;
    
    $position1  = 'start' if !defined $position1;
    $position2  = 'end' if !defined $position2;
    
    my @date    = split(/\/|-/x, $new_date);
    my @current = Today();
    
    my $start   = get_season_month($season, $position1);
    my $end     = get_season_month($season, $position2);
       
    if($current[1] >= $start && $current[1] <= $end) {
        return sprintf("%04d/%02d/%02d", Add_Delta_Days(Today, 7));
    }
    
    return $new_date;
}
1;

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut
