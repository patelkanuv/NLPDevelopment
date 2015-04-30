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

package Travel::Search::Date::ComplexDate::Parser;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use Date::Calc qw(Today Delta_Days);
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use lib qw(../../../../);
use Travel::Search::Date::ComplexDate::Month;
use Travel::Search::Date::ComplexDate::Season;
use Travel::Search::Date::ComplexDate::WeekDay;

has 'travel_dates'  => (is => 'rw', isa => 'ArrayRef[HashRef]');
has 'date_counter'  => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'expected_count'=> (is => 'rw', isa => 'Int', default => sub { 2 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

with 'Travel::Search::Date::Basic';

sub parse_complex_travel_dates {
    my ($self)  = @_;
    
    my $date_parser = Travel::Search::Date::ComplexDate::Month->new(
                        tokens          => $self->tokens,
                        expected_count  => $self->get_expected_date_count
                    );
    my $travel_dates= $date_parser->parse_travel_dates_around_month_name();
    $self->mix_parsed_dates($travel_dates);

    if($self->expected_count != $self->date_counter) {
        my $day_parser  = Travel::Search::Date::ComplexDate::WeekDay->new(
                            tokens          => $self->tokens,
                            expected_count  => $self->get_expected_date_count
                        );
        my $day_dates  = $day_parser->parse_travel_dates_around_day_name();
        $self->mix_parsed_dates($day_dates);
    }
    
    if($self->expected_count != $self->date_counter) {
        my $day_parser  = Travel::Search::Date::ComplexDate::Season->new(
                            tokens          => $self->tokens,
                            expected_count  => $self->get_expected_date_count
                        );
        my $season_dates = $day_parser->parse_travel_dates_around_season_name();
        $self->mix_parsed_dates($season_dates);
    }
    
    if($self->expected_count != $self->date_counter) {
        $self->parse_unused_complex_keywords();
    }
    
    return $self->travel_dates;
}

sub mix_parsed_dates {
    my($self, $travel_dates)    = @_;
    
    foreach my $date (@{$travel_dates}){
        last if $self->expected_count == $self->date_counter;
        $self->date_counter($self->date_counter + 1);
        my $dates       = $self->travel_dates;
        push(@{$dates}, $date);
        $self->travel_dates($dates);
    }
    
    return ;
}

sub parse_unused_complex_keywords {
    my($self)    = @_;
    
    foreach my $token(@{$self->tokens->get_tokens_byData('weekend')}) {
        next if $token->is_used;
        next if $self->expected_count == $self->date_counter;
        
        my $new_date1  = $self->get_next_weekday('saturday');
        if( $self->is_valid_date($new_date1)) {
            $self->validate_date($new_date1, $token);
            if($token->parsed_as eq 'Date') {
                last;
            }
        }
    }
    
    return;
}

1;
=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut