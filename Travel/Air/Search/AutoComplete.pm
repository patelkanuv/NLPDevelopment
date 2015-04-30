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

package Travel::Air::Search::AutoComplete;

=head1 NAME

Travel::Air::Search::AutoComplete - provides help to customer to autocomplete their open text queries.

=head1 SYNOPSIS

    use Travel::Air::Search::AutoComplete;
    my $token       = Travel::Air::Search::AutoComplete->new( data => $str);
    my $token       = $token->get_suggestions();

=head1 DESCRIPTION

This class will generate autocomplete help from various sources like worldairportlist, dictionary, autocomplete table etc.

=cut

use Moose; # automatically turns on strict and warnings
use Try::Tiny;
use Data::Dumper;

use lib qw(../../../);
use Travel::Search::Tokens;
use Travel::Cache::DataCenter;
use General::SpellCheck::Simple;
use Travel::Search::Airport::Parser;

=head1 ATTRIBUTES

=head2 datacenter ( rw / default value )

database and Cache Interface object.

=head2 data ( rw / user supplied value )

its a word

=cut

has 'datacenter'    => (is => 'rw', isa => 'Travel::Cache::DataCenter', default => sub { Travel::Cache::DataCenter->new });
has 'word1'         => (is => 'rw', isa => 'Str');
has 'word2'         => (is => 'rw', isa => 'Str');
has 'search_text'   => (is => 'rw', isa => 'Str');
has 'airport_cnt'   => (is => 'rw', isa => 'Int', default => sub { 0 });
has 'suggestions'   => (is => 'rw', isa => 'Any', default => sub { [] });

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;

    my $word1   = $self->word1;
    $word1      =~ s/\s+$//x;
    $self->word1($word1);
    
    my $word2   = $self->word2;
    $word2      =~ s/\s+$//x;
    $self->word2($word2);
    
    my $search_text = $self->search_text;
    $search_text    =~ s/\s+$//x;
    my @words       = split(/,\s*|\s+/x, $search_text);
    pop(@words);
    $search_text    = join(" ", @words);
    
    try {
        my $tokens  = Travel::Search::Tokens->new( data_str => $search_text );
        my $parser  = Travel::Search::Airport::Parser->new(tokens => $tokens);
        $parser->parse_airport;
        $self->airport_cnt($parser->match_cnt);
    }
    catch{
        print STDERR $_;
    };
    
    return;
}

=head2 get_suggestions

get_suggestions method will check whole search string if 2 airports found then will try to give suggestions
on airport.In normal case it will give you autocomplete suggestion based on city/airport and over own database
designed for the autocomplete keywords. 

=cut

sub get_suggestions {
    my($self)    = @_;

    #Travel common token suggestions
    $self->add_to_matched_result($self->datacenter->get_travel_keywords_like($self->word2));
    if(length($self->word1) >= 3 && $self->word1 ne $self->word2) {
        $self->add_to_matched_result($self->datacenter->get_travel_keywords_like($self->word1));
    }
    #Airport Suggestions
    if($self->airport_cnt < 2) {
        $self->add_to_matched_result($self->datacenter->get_airport_city_like($self->word2));
        if(length($self->word1) >= 3 && $self->word1 ne $self->word2) {
            $self->add_to_matched_result($self->datacenter->get_airport_city_like($self->word1));
        }
    }
    
    return $self->suggestions;
}

=head2 spelling_check

spelling_check will return any spell suggestion in autocomplete format. 

=cut

sub spelling_check {
    my ($self, $string) = @_;
    my @data    = split(/\s+/x, $string);

    my $dictionary  = General::SpellCheck::Simple->new();
    my @suggestions = $dictionary->suggestions($string);
    
    my @result;
    foreach my $suggestion (@suggestions) {
        foreach my $word(@{ $suggestion->{ $string } }){
            my %hash;
            $hash{ 'label' }    = $word;
            $hash{ 'value' }    = $word;
            push(@result, \%hash);
        }
       
    }
    
    return \@result;
}

=head2 add_to_matched_result

add_to_matched_result will add result to suggestions attribute from various source, It will preserve the
previous suggestions and will add it at the last available space. 

=cut

sub add_to_matched_result {
    my ($self, $suggestion) = @_;
    
    my @result;
    
    foreach my $suggestion (@{$self->suggestions}) {
        push(@result, $suggestion);
    }
    
    foreach my $suggestion (@{$suggestion}) {
        push(@result, $suggestion);
    }

    $self->suggestions(\@result);
    return;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;