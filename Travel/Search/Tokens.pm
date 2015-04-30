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

package Travel::Search::Tokens;

=head1 NAME

Travel::Search::Tokens - Transforms a search string into small chunks of Token L<Travel::Search::Token>

=head1 SYNOPSIS

    use Travel::Search::Tokens;
    my $token       = Travel::Search::Tokens->new( data_str => 'Want cheap fares to Las Vegas in February');
    my $token       = $token->get_first_token();
    my $token       = $token->get_next_token($token);
    my $token       = $token->get_prev_token($token);
    my $tokens      = $token->get_regular_token();
    my $token       = $token->get_token_byData('to');


=head1 DESCRIPTION

Tokens class does global replacement of words in search string. does spell check, replaces various abbreviations
with its proper string. Replaces Two or more word country names with their respective country code. It divides
search string into large # of Token and provides reach set of functions to retrieves tokens.

=cut

use Carp;
use Moose; # automatically turns on strict and warnings
use Data::Dumper;
use Try::Tiny;

use lib qw(../../);
use General::SpellCheck::Simple;
use Travel::Search::Token;
use Travel::Data::Replacer qw(
    replace_country_name
    replace_search_abbreviations
    replace_month_strings
    spelling_check
);
use Travel::Data::Dictionary qw(
    is_this_word_start_of_cityname 
    is_this_word_calendar_abbreviation 
    is_this_word_three_letter_verb
);

=head1 ATTRIBUTES

=head2 data_str ( rw / required field )

Its search string which is supplied for parsing.

=head2 IP ( rw / user supplied value )

Valid IP address of customer who requested a search to parse.

=head2 tokens ( rw / built automatically )

Tokens are list(array) of L<Travel::Search::Token>

=head2 token_count ( rw / built automatically )

Its # of token generated from the data_str

=cut

has 'IP'            => (is => 'rw', isa => 'Str', lazy => 1, default => sub { '1.1.1.1' });
has 'data_str'      => (is => 'rw', isa => 'Str');
has 'tokens'        => (is => 'rw', isa => 'ArrayRef[ Travel::Search::Token ]');
has 'token_count'   => (is => 'rw', isa => 'Int');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;

    my @tokens;
    my $position= 1;
    my $string  = lc($self->data_str);
    
    if ( !defined $string) {
        croak 'You can not create empty tokens';
    }
    
    $string =~ s/,|`|_|\(|\)|%/ /gx; #replace special characters with space
    $string = spelling_check($string);
    $string = replace_country_name($string);
    $string = replace_search_abbreviations($string);
    $string = replace_month_strings($string);
    
    $string =~ s/^\s+//x; #remove leading spaces
    $string =~ s/\s+$//x; #remove trailing spaces

    my @data        = split(/\s+/x, $string);
    my $dictionary  = General::SpellCheck::Simple->new();
    foreach my $key (@data) {
        if ($key !~ /\d/x && $key =~ /-/x) {
            my @new_data    = split("-", $key);
            foreach my $new_key(@new_data) {
                push(@tokens,   Travel::Search::Token->new(
                                    data        => $new_key,
                                    position    => $position++,
                                    dictionary  => $dictionary
                                )
                );
            }
        }
        elsif($key =~ /\d/x && $key =~ /\D/x && $key !~ /-|\//x && $key !~ /(st|nd|rd|th)/x) {
            my @new_data;
            if($key =~ /^\d/x){
                ($new_data[0], $new_data[1]) = $key =~ /(\d+)(\w+)/x;
            }
            else {
                ($new_data[0], $new_data[1]) = $key =~ /(\w+)(\d+)/x;
            }
            foreach my $new_key(@new_data) {
                push(@tokens,   Travel::Search::Token->new(
                                    data => $new_key,
                                    position => $position++,
                                    dictionary  => $dictionary
                                )
                );
            }
        }
        else {
            push(@tokens,   Travel::Search::Token->new(
                                data        => $key,
                                position    => $position++,
                                dictionary  => $dictionary
                            )
            );
        }
    }
    
    $self->token_count(scalar(@tokens));
    $self->tokens(\@tokens);
    
    return ;
}

=head2 get_first_token

get_first_token function returns the first token in the list

=cut

sub get_first_token {
    my ($self)  = @_;
    
    return $self->tokens->[0];
}

=head2 get_last_token

get_last_token function returns the last token in the list

=cut

sub get_last_token {
    my ($self)  = @_;
    
    return $self->tokens->[ $self->token_count - 1];
}

=head2 get_next_token($token)

get_next_token function returns the very next token that comes after $token, $token should be a Valid token.
It will return undef if $token is last token.

=cut

sub get_next_token {
    my ($self, $token)  = @_;
    
    croak "Not a Travel::Search::Token" if ref($token) ne 'Travel::Search::Token';
    my $position = $token->position;
    my $flag = 0;
    foreach my $tok (@{ $self->tokens }) {
        return $tok if $flag;
        next if $tok->position != $position;
        $flag = 1;
    }
    
    return ;
}

sub get_next_token_and_data {
    my($self, $token)  = @_;
    
    my ($next_token, $next_token_data);
    try {
        $next_token     = $self->get_next_token($token);
        $next_token_data= lc($next_token->data);
    }
    catch {
        print STDERR "Error: $_";
    };
    
    return ($next_token, $next_token_data);
}


=head2 get_prev_token($token)

get_prev_token function returns the immediate previous token that comes before $token, $token should be a Valid token.
It will return undef if $token is first token.

=cut

sub get_prev_token {
    my ($self, $token)  = @_;
   
    croak "Not a Travel::Search::Token" if ref($token) ne 'Travel::Search::Token'; 
    my $position = $token->position;
    my $prev;
    foreach my $tok (@{ $self->tokens }) {
        return $prev if $tok->position == $position;
        $prev   = $tok;
    }
    return ;
}

sub get_prev_token_and_data {
    my($self, $token)  = @_;
    
    my ($prev_token, $prev_token_data);
    try {
        $prev_token     = $self->get_prev_token($token);
        $prev_token_data= lc($prev_token->data);
    }
    catch {
        print STDERR "Error: $_";
    };
    
    return ($prev_token, $prev_token_data);
}

=head2 get_unused_next_token($token)

get_unused_next_token function returns the very next token that comes after $token if its unsed, $token should be a Valid token.
It will return undef if $token is last token or the next token is used one.

=cut

sub get_unused_next_token {
    my ($self, $token)  = @_;
    
    my $tok = $self->get_next_token($token);
    return $tok if !$tok->is_used;
    return ;
}

=head2 get_unused_prev_token($token)

get_unsed_prev_token function returns the immediate previous token that comes before $token if unused, $token should be a Valid token.
It will return undef if $token is first token or the previous token is used one.

=cut

sub get_unused_prev_token {
    my ($self, $token)  = @_;
   
    my $tok = $self->get_prev_token($token);
    return $tok if !$tok->is_used;
    return ;
}

sub get_two_prev_token_data {
    my ($self, $token)  = @_;
   
    my $string  = '';
    try {
        my $tok1 = $self->get_prev_token($token);
        my $tok2 = $self->get_prev_token($tok1);
        $string  = $tok2->data;
        $string  .= ' '.$tok1->data;
    };
    
    return $string;
}

sub mark_two_prev_token_data {
    my ($self, $token, $string)  = @_;

    try {
        my $tok1 = $self->get_prev_token($token);
        my $tok2 = $self->get_prev_token($tok1);
        
        $tok1->token_parsed_as($string);
        $tok2->token_parsed_as($string);
    };
    
    return ;
}

sub get_two_next_token_data {
    my ($self, $token)  = @_;
   
    my $string  = '';
    try {
        my $tok1 = $self->get_next_token($token);
        my $tok2 = $self->get_next_token($tok1);
        $string  = $tok1->data;
        $string  .= ' '.$tok2->data;
    };
    
    return $string;
}

sub mark_two_next_token_data {
    my ($self, $token, $string)  = @_;

    try {
        my $tok1 = $self->get_next_token($token);
        my $tok2 = $self->get_next_token($tok1);

        $tok1->token_parsed_as($string);
        $tok2->token_parsed_as($string);

    };
    
    return ;
}

=head2 get_regular_token

get_regular_token will return all the tokens which class is 'Regular'

=cut

sub get_regular_token {
    my ($self)  = @_;
    
    my @tokens;    
    foreach my $tok (@{ $self->tokens }) {
        next if $tok->class ne 'Regular';
        push (@tokens, $tok);
    }
    return \@tokens;
}

=head2 get_token_byData($data)

get_token_byData returns the first matching token with $data, The match is performed with token's data attribute.
In case of no match it returns undef.

=cut

sub get_token_byData {
    my ($self, $data) = @_;
    
    foreach my $token (@{ $self->tokens }) {
        next if $token->data ne lc($data);
        return $token;
    }
    return;
}

=head2 get_tokens_byData($data)

get_tokens_byData returns the array of matching token with $data, The match is performed with token's data attribute.
In case of no match it returns empty array.

=cut

sub get_tokens_byData {
    my ($self, $data) = @_;
    
    my @tokens  = ();
    foreach my $token (@{ $self->tokens }) {
        next if $token->data ne lc($data);
        push (@tokens, $token);
    }
    return \@tokens;
}

=head2 get_tokens_byData_like($data)

get_tokens_byData_like returns the array of matching token with $data, The match is performed with token's data attribute.
In case of no match it returns empty array.The match is partial, the $data should match fully or partially to the
matching tokens.

=cut

sub get_tokens_byData_like {
    my ($self, $data) = @_;
    
    my @tokens  = ();
    foreach my $token (@{ $self->tokens }) {
        next if $token->data !~ lc($data);
        push (@tokens, $token);
    }
    return \@tokens;
}

=head2 get_tokens_byClass($class)

get_tokens_byClass returns the array of matching token with $data, The match is performed with token's class attribute.
In case of no match it returns empty array.

=cut

sub get_tokens_byClass {
    my ($self, $class) = @_;
    
    my @tokens;
    foreach my $token (@{ $self->tokens }) {
        next if lc($token->class) ne lc($class);
        push (@tokens, $token);
    }
    return @tokens;
}

=head2 get_token_byPosition($position)

get_token_byPosition returns the matching token with $position, The match is performed with token's position attribute.
In case of no match it returns undef.

=cut

sub get_token_byPosition {
    my ($self, $position) = @_;
    
    my @tokens  = ();
    foreach my $token (@{ $self->tokens }) {
        if($token->position ==  $position) {
            return $token;
        }
    }
    return ;
}

=head2 get_tokens_data_with_number

get_tokens_data_with_number returns the array of matching token which has numeric value in data attribute.
In case of no match it returns empty array.

=cut

sub get_tokens_data_with_number {
    my ($self) = @_;
    
    my @tokens  = ();
    foreach my $token (@{ $self->tokens }) {
        if($token->has_number ) {
            push (@tokens, $token);
        }
    }
    return \@tokens;
}

=head2 get_regular_misspelled_tokens

get_regular_misspelled_tokens returns the array of matching token which has wrong spelling.
In case of no match it returns empty array.

=cut

sub get_regular_misspelled_tokens {
    my ($self) = @_;
    
    my @tokens  = ();
    foreach my $token (@{ $self->tokens }) {
        if(!$token->is_spell_correct && $token->class eq 'Regular') {
            push (@tokens, $token);
        }
    }
    return @tokens;
}

=head2 get_possible_airport_codes

get_possible_airport_codes returns the array of matching token which has data with length of 3 digit and words.
In case of no match it returns empty array.

=cut

sub get_possible_airport_codes {
    my ($self)  = @_;
    
    my @tokens;    
    foreach my $token (@{ $self->get_regular_token }) {
        next if length($token->data) != 3;
        next if $token->has_number;
        if( !is_this_word_start_of_cityname($token->data) 
            && !is_this_word_calendar_abbreviation($token->data)
            && !is_this_word_three_letter_verb($token->data)) {
            push (@tokens, $token);
        }
    }
    
    return @tokens;
}

=head2 get_flagged_airport_codes

get_flagged_airport_codes returns the array of matching token which has data with length of 3 digit and words.
This word can be also starting names of any city, i.e Las which is starting name of Las Vegas. In case of no match it returns empty array.

=cut

sub get_flagged_airport_codes {
    my ($self)  = @_;
    
    my @tokens;    
    foreach my $token (@{ $self->get_regular_token }) {
        next if length($token->data) != 3;
        next if $token->has_number;
        if( is_this_word_start_of_cityname($token->data)) {
            push (@tokens, $token);
        }
    }
    
    return @tokens;
}

=head2 get_flagged_calendar_abbreviation

get_flagged_calendar_abbreviation returns the array of matching token which has data with length of 3 digit and words.
The 3 letter word can be either Month or weekday starting, i.e Mon for Monday. In case of no match it returns empty array.

=cut

sub get_flagged_calendar_abbreviation {
    my ($self)  = @_;
    
    my @tokens;    
    foreach my $token (@{ $self->get_regular_token }) {
        next if length($token->data) != 3;
        if( is_this_word_calendar_abbreviation($token->data)) {
            push (@tokens, $token);
        }
    }
    
    return @tokens;
} 

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;
