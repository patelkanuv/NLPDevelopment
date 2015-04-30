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

package Travel::Search::Date::Basic;

use Carp;
use Try::Tiny;
use Moose::Role;
use Data::Dumper;
use Date::Manip::Date;
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../);
use Travel::Data::Config qw(weekday_to_number);

requires qw(travel_dates date_counter expected_count);

sub validate_date {
    my($self, $date, $token)    = @_;

    my $position    = $token->position;
    my @cur_date    = Today();
    my @given_date  = split(/-|\.|\//x, $date);
    #Year

    try {
        my $dd  = Delta_Days(
                    $cur_date[0],   $cur_date[1],   $cur_date[2],
                    $given_date[0], $given_date[1], $given_date[2]
                );
        if($dd >= 0){
            my $new_date    = sprintf("%04d/%02d/%02d", $given_date[0], $given_date[1], $given_date[2]);
            my $dates       = $self->travel_dates;
            my $date_data   = {
                'date'      => $new_date,
                'position'  => $position
            };
            push(@{$dates}, $date_data);
            $self->travel_dates($dates);
            $self->date_counter($self->date_counter + 1);
            $self->mark_as_used_date([$token]);
        }
    }
    catch {
        #Invalid date
        print STDERR $_,"\n";
    };
    
    return;
}

sub is_valid_date {
    my($self, $date)    = @_;

    my @cur_date    = Today();
    my @given_date  = split(/-|\.|\//x, $date);
    #Year
    my $flag    = 0;
    try {
        my $dd  = Delta_Days(
                    $cur_date[0],   $cur_date[1],   $cur_date[2],
                    $given_date[0], $given_date[1], $given_date[2]
                );
        if($dd >= 0){
            $flag   = 1;
        }
    }
    catch {
        #Invalid date
        print STDERR $_,"\n";
    };
    
    return $flag;
}

sub autocomplete_day_in_date {
    my($self, $year, $month)    = @_;
    
    my @cur_date    = Today();
    my $day         = 1;
    #current year == year and month == current month
    if(defined $year && $year == $cur_date[0] && $month == $cur_date[1]){
        $day        = $cur_date[2];
    }
    elsif($month == $cur_date[1]) {
        $day        = $cur_date[2];
    }
    
    return $day;
}

sub autocomplete_year_in_date {
    my($self, $month, $dd)    = @_;

    my @cur_date    = Today();
    my $year        = $cur_date[0];
    #month < current month
    if($month < $cur_date[1]){
        $year       = $cur_date[0] + 1;
    }
    elsif($month == $cur_date[1] && $dd < $cur_date[2]){
        $year       = $cur_date[0] + 1;
    }
    
    return $year;
}

sub mark_as_used_date {
    my($self, $tokens)    = @_;
    
    foreach my $token(@{$tokens}){
        $token->mark_token_used;
        $token->parsed_as('Date');
    }
    
    return ;
}

sub get_expected_date_count {
    my($self)    = @_;
    
    return $self->expected_count - $self->date_counter;
}

sub get_date_from_sentence {
    my($self, $sentence)    = @_;
    
    my $date_parser = Date::Manip::Date->new();
    $date_parser->parse( $sentence );
    my @dates   = $date_parser->value;
    
    $date_parser->parse( 'today' );
    my @current   = $date_parser->value;
    
    if($dates[0] == $current[0] && $dates[1] < $current[1]){
        $dates[0]++;
    }
    
    return sprintf("%04d/%02d/%02d", $dates[0], $dates[1], $dates[2]);
}

sub get_nearest_weekend {
    my ($self, $date)    = @_;

    my $current = $self->get_current_weekday($date);
    
    if($current eq 'saturday') {
        return $date;
    }
    elsif($current eq 'sunday') {
        return sprintf("%04d/%02d/%02d", Add_Delta_Days(split(/\/|-/x, $date), -1));
    }
    else {
        return $self->get_next_weekday('saturday', $date);
    }
    
    return ;
}

sub get_next_weekday {
    my ($self, $day, $date)    = @_;
    
    my $diff    = 0;
    my $current = $self->get_current_weekday($date);

    if(weekday_to_number($current) >= weekday_to_number($day)) {
        $diff   = 7 - weekday_to_number($current) + weekday_to_number($day);
    }
    else {
        $diff   = weekday_to_number($day) - weekday_to_number($current);
    }
    
    if($date) {
        my @date    = split(/\//x, $date);
        return sprintf( "%04d/%02d/%02d",
                        Add_Delta_Days(
                              $date[0],
                              $date[1],
                              $date[2],
                              $diff
                            )
                        );
    }
    return sprintf("%04d/%02d/%02d", Add_Delta_Days(Today,$diff));
}

sub get_current_weekday {
    my ($self, $date)  = @_;
    
    my $date_parser = Date::Manip::Date->new();
    $date_parser->parse( 'today' );
    my @dates;
    if($date) {
        @dates  = split(/\//x, $date);
    }
    else {
        @dates  = $date_parser->value;
    }
    
    
    return lc(Day_of_Week_to_Text( Day_of_Week($dates[0], $dates[1], $dates[2])));
}

1;

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut
