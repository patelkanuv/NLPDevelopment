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

package Travel::Search::Airport::Parser;

use Carp;
use Moose;
use Data::Dumper;
use Try::Tiny;

use lib qw(../../../);
use Travel::Data::Airport;
use Travel::Cache::DataCenter;
use Travel::Database::Schema::Result::City;
use Travel::Search::Airport::SpellingCorrector;
use Travel::Data::Dictionary qw(is_this_city_in_more_than_one_country invalid_province_to_use);

has 'IP'        => (is => 'rw', isa => 'Str', lazy => 1, default => sub { '1.1.1.1' });
has 'match_cnt' => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'tokens'    => (is => 'rw', isa => 'Travel::Search::Tokens');
has 'datacenter'=> (is => 'rw', isa => 'Travel::Cache::DataCenter', default => sub { Travel::Cache::DataCenter->new });

has 'depart_position'   => (is => 'rw', isa => 'Int');
has 'return_position'   => (is => 'rw', isa => 'Int');
has 'depart_airport'    => (is => 'rw', isa => 'ArrayRef[Travel::Database::Schema::Result::City]');
has 'return_airport'    => (is => 'rw', isa => 'ArrayRef[Travel::Database::Schema::Result::City]');
has 'ip_based_airport'  => (is => 'rw', isa => 'ArrayRef[Travel::Database::Schema::Result::City]');

sub parse_airport {
    my ($self)  = @_;
    
    $self->city_name_spell_correction();
    $self->city_name_with_from;
    $self->city_name_with_to;
    $self->parse_straight_token;
    $self->parse_misspelled_city_names;
    $self->parse_airport_codes;
    $self->parse_flagged_airport_codes;
    $self->parse_country_code;
    $self->parse_state_province_code;
    $self->get_ip_based_airport_code;
    #$self->parse_flagged_calendar_abbreviation;
    $self->adjust_airport_details;
    
    return($self->depart_airport, $self->return_airport);
}

sub city_name_spell_correction {
    my($self) = @_;
    
    my $spell_corrector = Travel::Search::Airport::SpellingCorrector->new(tokens => $self->tokens);
    $spell_corrector->make_spell_correction();
    return;
}

sub parse_airport_codes {
    my ($self)  = @_;
    
    foreach my $token ($self->tokens->get_possible_airport_codes) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        
        $self->_process_airport_code($token);
    }
    
    return;
}

sub city_name_with_from {
    my ($self)  = @_;
    
    my $from_tokens     = $self->tokens->get_tokens_byData('from');
    $self->_parse_airport_city_name_tokens($from_tokens);   
    return;
}

sub city_name_with_to {
    my ($self)  = @_;
    
    my $to_tokens    = $self->tokens->get_tokens_byData('to');
    $self->_parse_airport_city_name_tokens($to_tokens);   
    return ;
}

sub _parse_airport_city_name_tokens {
    my ($self, $airport_name_tokens)   = @_;
    
    foreach my $airport_name_token (@{$airport_name_tokens}) {
        next if $airport_name_token->is_used;
        my $airport_found_flag   = 0;
        my $index       = 3;
        foreach my $city($self->_get_neighbouring_tokens_data($airport_name_token)) {
            #print $city,"\n";
            $index--;
            next if !defined $city;
            my $all_airports = $self->datacenter->match_by_city_name($city);
            if(scalar(@{$all_airports}) >= 1) {
                $self->_mark_similar_city_with_more_words_used($city, $airport_name_token->position);
                $self->store_at_target($all_airports, $airport_name_token->position+1);
                $airport_found_flag = 1;
                my $token   = $airport_name_token;
                for( my $i = $index + 1; $i >= 1; $i--) {
                    my $next_token  = $self->tokens->get_next_token($token);
                    if(ref($next_token) eq 'Travel::Search::Token') {
                        $token  = $next_token;
                        $token->parsed_as('City/Airport');
                        $next_token->mark_token_used;
                        $next_token->parsed_as('City/Airport');
                    }
                }
                $self->city_name_with_airport_code($city, $token);
                last;
               
            }            
        }
        last if $airport_found_flag == 1;
    }
    
    return;
}



sub parse_straight_token {
    my ($self)  = @_;
    
    foreach my $token (@{ $self->tokens->get_regular_token }) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        
        my $next_token  = $self->tokens->get_next_token($token);
        my $all_airports = $self->_get_matching_airports($token);
        if(scalar(@{$all_airports}) >= 1) {
            $self->_mark_similar_city_used($token->data, $token->position);
            $self->_mark_similar_city_with_more_words_used($token->data, $token->position);
            $self->city_name_with_airport_code($token->data, $token);
        }
        else {
            next if(ref($next_token) ne 'Travel::Search::Token');
            $all_airports = $self->_get_matching_airports($token, $next_token);
            if(scalar(@{$all_airports}) < 1) {
                my $next_to_next_token  = $self->tokens->get_next_token($next_token);
                next if(ref($next_to_next_token) ne 'Travel::Search::Token');
                $all_airports = $self->_get_matching_airports($token, $next_token, $next_to_next_token);
            }
        }
    }
    return;
}

sub _get_matching_airports {
    my ($self, @tokens) = @_;
    
    my $string;
    foreach my $token (@tokens) {
        if($string) {
            $string .= " ".$token->data;
        }
        else {
            $string = $token->data;
        }
    }
    
    $string =~ s/-/ /gx;
    my $all_airports = $self->datacenter->match_by_city_name($string);
    if(scalar(@{$all_airports}) >= 1) {
        $self->_mark_similar_city_with_more_words_used($string, $tokens[0]->position);
        map { $_->token_parsed_as('City/Airport'); } @tokens;
        $self->store_at_target($all_airports, $tokens[0]->position);
        $self->city_name_with_airport_code($string, $tokens[ scalar(@tokens) - 1 ]);
        return $all_airports;
    }
    
    return $all_airports;
}

sub store_at_target {
    my ($self, $airports, $postion)   = @_;
    
    $self->match_cnt($self->match_cnt + 1);
    $self->overwrite_store_at_target($airports, $postion);
    
    return;
}

sub overwrite_store_at_target {
    my ($self, $airports, $position )   = @_;
    
    $self->mark_coutry_province_used($airports->[0], $position);
    
    if($self->match_cnt == 1) {
        $self->depart_position($position);
        $self->depart_airport($airports);
    }
    elsif($self->match_cnt == 2) {
        $self->return_position($position);
        $self->return_airport($airports);
    }
    
    return;
}

sub parse_flagged_airport_codes {
    my ($self)  = @_;
    
    foreach my $token ($self->tokens->get_flagged_airport_codes) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        
        $self->_process_airport_code($token);
    }
    return;    
}

sub parse_misspelled_city_names {
    my ($self)  = @_;
    
    foreach my $token ($self->tokens->get_regular_misspelled_tokens) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        next if length($token->data) <= 3;
        
        my $dictionary  = General::SpellCheck::Simple->new();
        my @suggestions = $dictionary->suggestions($token->data);
        
        if(scalar(@suggestions) >= 1 ) {
            foreach my $new_city(@{$suggestions[0]->{ $token->data } }) {

                my %possible_city;
                $possible_city{ $new_city }  = 1;
                
                my ($prev_token, $next_token);
                try {
                    $prev_token = $self->tokens->get_prev_token($token);
                    my $str     = $prev_token->data." ".$new_city;
                    $possible_city{ $str }  = 1;
                }
                catch { 
                    print $_,"\n";
                };
                
                try {
                    $next_token = $self->tokens->get_next_token($token);
                    my $str     = $new_city." ".$next_token->data;
                    $possible_city{ $str }  = 1;
                }
                catch { 
                    print $_,"\n";
                };
                
                my $new_token   = $token->clone;
                
                foreach my $key (keys %possible_city) {
                    $new_token->replace_data(lc($key));
                    my $all_airports = $self->_get_matching_airports($new_token);
                    if(scalar(@{$all_airports}) >= 1) {
                        $self->_mark_similar_city_used($token->data, $token->position);
                        $self->_mark_similar_city_used($new_token->data, $token->position);
                        $self->_mark_similar_city_with_more_words_used($new_token->data, $token->position);
                        $self->city_name_with_airport_code($new_token->data, $token);
                        $token->mark_token_used;
                        $token->replace_data($new_city);
                        $token->parsed_as('City/Airport');
                        foreach(split(" ",$new_token->data)) {
                            next if $_ eq $key;
                            my $extra_token = $self->tokens->get_token_byData($_);
                            try { $extra_token->mark_token_used; $extra_token->parsed_as('City/Airport'); };
                        }
                        
                        return;
                    }
                }
            }
        }
    }
    
    return ;
}

sub parse_flagged_calendar_abbreviation {
    my ($self)  = @_;
    
    foreach my $token ($self->tokens->get_flagged_calendar_abbreviation) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        
        $self->_process_airport_code($token);
    }
    return;
}

sub _process_airport_code {
    my ($self, $token)  = @_;
    
    my $all_airports = $self->datacenter->match_by_airport_code($token->data);
    if(scalar(@{$all_airports}) >= 1) {
        $token->mark_token_used;
        $token->parsed_as('City/Airport');
        $self->store_at_target($all_airports, $token->position);
        foreach my $data ($all_airports->[0]->city_name, $all_airports->[0]->airport_name) { 
            foreach my $data_part(split(/\s+/x, $data)) {
                my $tokens = $self->tokens->get_tokens_byData(lc($data_part));
                foreach my $tok (@{$tokens}){
                    $tok->mark_token_used;
                    $tok->parsed_as('City/Airport');
                }
            }
        }        
    }
    
    return;
}

sub get_ip_based_airport_code {
    my ($self)  = @_;
    
    return if $self->match_cnt >= 2;
    my $airport = $self->datacenter->get_nearest_airport( $self->IP);
    if($airport){
        $self->ip_based_airport( $airport );
    }
    return;
}

sub adjust_airport_details {
    my ($self)  = @_;
    
    return if $self->match_cnt == 0;
    if ($self->match_cnt == 1 ) {
        if($self->ip_based_airport) {
            $self->return_airport($self->depart_airport);
            $self->depart_airport($self->ip_based_airport);
        }
        
        return;
    }
    my $keyword_flag    = 0;
    #TODO Refactor this function
    my $to_tokens    = $self->tokens->get_tokens_byData('to');
    foreach my $to_token(@{$to_tokens}) {
        $keyword_flag   = 1;
        my ($third_data, $second_data, $next_data)
            = $self->_get_neighbouring_tokens_data($to_token);
        
        if($to_token->position < $self->depart_position &&
           (lc($self->depart_airport->[0]->city_name) eq $next_data
            || lc($self->depart_airport->[0]->city_name) eq $second_data
            || lc($self->depart_airport->[0]->city_name) eq $third_data
            || lc($self->depart_airport->[0]->airport_code) eq $next_data)) {
            my ($from, $to) = ($self->depart_airport, $self->return_airport);
            $self->depart_airport($to);
            $self->return_airport($from);
            
            my ($from_pos, $to_pos) = ($self->depart_position, $self->return_position);
            $self->depart_position($to_pos);
            $self->return_position($from_pos);
            return;
        }
        
    }
    
    my $from_tokens    = $self->tokens->get_tokens_byData('from');
    foreach my $from_token (@{$from_tokens}) {
        $keyword_flag   = 1;
        my ($third_data, $second_data, $next_data)
            = $self->_get_neighbouring_tokens_data($from_token);

        if($from_token->position > $self->depart_position &&
           (lc($self->return_airport->[0]->city_name) eq $next_data
            || lc($self->return_airport->[0]->city_name) eq $second_data
            || lc($self->return_airport->[0]->city_name) eq $third_data
            || lc($self->return_airport->[0]->airport_code) eq $next_data)) {
            my ($from, $to) = ($self->depart_airport, $self->return_airport);
            $self->depart_airport($to);
            $self->return_airport($from);
            
            my ($from_pos, $to_pos) = ($self->depart_position, $self->return_position);
            $self->depart_position($to_pos);
            $self->return_position($from_pos);
            return;
        }
    }
    
    if($self->depart_position > $self->return_position && !$keyword_flag) {
        my ($from, $to) = ($self->depart_airport, $self->return_airport);
        my ($from_pos, $to_pos) = ($self->depart_position, $self->return_position);
        $self->depart_airport($to);
        $self->return_airport($from);
        $self->depart_position($to_pos);
        $self->return_position($from_pos);
    }

    return ;
}

sub _mark_similar_city_used {
    my ($self, $data, $position)  = @_;
    
    my $tokens  = $self->tokens->get_tokens_byData($data);
    foreach my $token (@{$tokens}) {
        next if $token->position == $position;
        $token->mark_token_used;
        $token->parsed_as('City/Airport');
        try {
            my $prev_token  = $self->tokens->get_prev_token($token);
            $position       = $token->position;
            if($prev_token->data eq 'from' || $prev_token->data eq 'to'){
                $self->_overwrite_position_of_last_match($position);
                return ;
            }
        };
    }
    
    return ;
}

#TODO Integrate and Test
sub _mark_similar_city_with_more_words_used {
    my ($self, $city_name, $position)  = @_;
    
    $city_name  =~ s/-/ /gx;
    my @data    = split(/\s+/x, $city_name);
    my $words   = scalar(@data); 
    my $tokens  = $self->tokens->get_tokens_byData($data[0]);
    
    foreach my $token (@{$tokens}) {
        next if $token->position == $position;
        my $prev_token  = $token;
        my $city        = $token->data;
        for(1..$words-1) {
            try {
                my $next_token  = $self->tokens->get_next_token($prev_token);
                $city   .= " ".$next_token->data;
                $prev_token     = $next_token;
            }
            catch {
                print STDERR "Error: $_";
            };
        }
        if($city eq $city_name) {
            $token->mark_token_used;
            $token->parsed_as('City/Airport');
            for(1..$words-1) {
                my $next_token  = $self->tokens->get_next_token($token);
                if(ref($next_token) eq 'Travel::Search::Token') {
                    $next_token->mark_token_used;
                    $next_token->parsed_as('City/Airport');
                    $token  = $next_token;
                }
            }

            try {
                $prev_token  = $self->tokens->get_prev_token($token);
                $position    = $token->position;
                if($prev_token->data eq 'from' || $prev_token->data eq 'to'){
                    $self->_overwrite_position_of_last_match($position);
                    return ;
                }
            };
        }
    }
    
    return ;
}

sub _overwrite_position_of_last_match {
    my ($self, $position)  = @_;
    
    if($self->match_cnt == 1) {
        $self->depart_position($position);
    }
    elsif($self->match_cnt == 2) {
        $self->return_position($position);
    }

    return;
}

sub _get_neighbouring_tokens_data {
    my($self, $main_token)  = @_;
    
    my ($next_data, $second_data, $third_data, $next_token, $second_token, $third_token);
    ($next_token, $next_data)       = $self->tokens->get_next_token_and_data($main_token);
    ($second_token, $second_data)   = $self->tokens->get_next_token_and_data($next_token);
    ($third_token, $third_data)     = $self->tokens->get_next_token_and_data($second_token);
    

    return (join(" ", $next_data, $second_data, $third_data), join(" ", $next_data, $second_data), $next_data);
}

sub parse_state_province_code {
    my ($self)  = @_;
    
    foreach my $token (@{ $self->tokens->get_regular_token }) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        
        my @tokens;
        push(@tokens, $token->data);
        
        try {
            my $next_token  = $self->tokens->get_next_token($token);
            my $next_data   = lc($next_token->data);
            if(!$next_token->is_used) {
                push(@tokens, $token->data.' '.$next_data);
            }
        }
        catch {
            print STDERR $_;
        };
        
        foreach my $state (@tokens) {
            next if !defined $state;
            next if invalid_province_to_use($state);
            
            my $all_airports = $self->datacenter->match_by_province_state_name($state);
            if(scalar(@{$all_airports}) >= 1) {
                $self->store_at_target($all_airports, $token->position);
                $token->mark_token_used;
                $token->parsed_as('City/Airport');
                $self->_mark_similar_city_used($state, $token->position);
                $self->_mark_similar_city_with_more_words_used($state, $token->position);
                $token->replace_data($all_airports->[0]->airport_code);
            }
        }
    }
    return;
}

sub parse_country_code {
    my ($self)  = @_;

    
    foreach my $token ($self->tokens->get_tokens_byClass('CountryCode') ) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        my $all_airports = $self->datacenter->match_by_country_code($token->data);
        
        if(scalar(@{$all_airports}) >= 1) {
            $self->store_at_target($all_airports, $token->position);
            $token->mark_token_used;
            $token->parsed_as('City/Airport');
            $self->_mark_similar_city_used($token->data, $token->position);
            $token->replace_data($all_airports->[0]->airport_code);
        }
    }
    
    foreach my $token (@{ $self->tokens->get_regular_token } ) {
        next if $token->has_number;
        next if $token->is_used;
        next if $self->match_cnt >= 2;
        my $all_airports = $self->datacenter->match_by_country_code($token->data);
        
        if(scalar(@{$all_airports}) >= 1) {
            $self->store_at_target($all_airports, $token->position);
            $token->mark_token_used;
            $token->parsed_as('City/Airport');
            $self->_mark_similar_city_used($token->data, $token->position);
            $token->replace_data($all_airports->[0]->airport_code);
        }
    }
    
    return;
}

sub city_name_with_airport_code {
    my ($self, $city_name, $token) = @_;
    
    my $next_token  = $self->tokens->get_next_token($token);
    try {
        if( ref($next_token) eq 'Travel::Search::Token' 
            and length($next_token->data) == 3) {
            
            my $all_airports   = $self->datacenter->match_by_city_name_and_airport_code(
                                    $city_name,
                                    $next_token->data
                                );
            if(scalar(@{$all_airports}) >= 1) {
                $next_token->mark_token_used;
                $next_token->parsed_as('City/Airport');
                $self->overwrite_store_at_target($all_airports, $token->position);
                $self->_mark_similar_city_used($next_token->data, $next_token->position);
            }
        }
    }
    catch {
        print STDERR "Error: $_";
    };
    
    return ;
}

sub mark_coutry_province_used {
    my ($self, $airport, $position) = @_;
    
    foreach my $key(qw/country_name country_code prov_name prov_code/) {
        next if!defined $airport->$key;
        $self->_mark_similar_city_used(lc($airport->$key), $position);
        $self->_mark_similar_city_with_more_words_used(lc($airport->$key), $position);
    }
    return;
}

1;
=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut