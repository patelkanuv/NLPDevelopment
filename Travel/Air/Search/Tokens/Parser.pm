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

package Travel::Air::Search::Tokens::Parser;

=head1 NAME

Travel::Air::Search::Tokens::Parser -It invokes various parsers to parse the given data string into means
of various Travel keywords or required words.

=head1 SYNOPSIS

    use Travel::Air::Search::Tokens::Parser;
    my $parser      = Travel::Air::Search::Tokens::Parser->new( data_str => 'London');
    $token->parse_input();
    


=head1 DESCRIPTION

Travel::Air::Search::Tokens::Parser invokes Airport Parser, Date parser, passenger parser, other parsers to
parse the various means from the given data string.

=cut

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
use Travel::Data::Airport;
use Travel::Search::Tokens;
use Travel::Search::Date::Parser;
use Travel::Search::Airport::Parser;
use Travel::Search::Passenger::Parser;
use Travel::Search::TripDetails::Parser;

=head1 ATTRIBUTES

=head2 data_str ( rw / required field )

Its search string which is supplied for parsing.

=head2 IP ( rw / user supplied value )

Valid IP address of customer who requested a search to parse.

=head2 tokens ( rw / built automatically )

Tokens are list(array) of L<Travel::Search::Token>

=head2 depart_airport ( rw / built automatically )

Its array of L<Travel::Data::Airport>

=head2 return_airport ( rw / built automatically )

Its array of L<Travel::Data::Airport>

=head2 depart_date ( rw / built automatically )

departure journey date

=head2 return_date ( rw / built automatically )

return journey date

=head2 pax_adult ( rw / built automatically )

Int value of adult passenger

=head2 pax_child ( rw / built automatically )

Int value of children passenger

=head2 pax_infant ( rw / built automatically )

Int value of infant passenger

=head2 trip_class ( rw / built automatically )

trip class of journey i.e Economy, Business Class, First Class

=head2 trip_type ( rw / built automatically )

Trip Type value, i.e OneWay or RoundTrip

=cut

has 'data_str'  => (is => 'rw', isa => 'Str');
has 'IP'        => (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'localhost' });
has 'tokens'    => (is => 'rw', isa => 'Travel::Search::Tokens');

has 'airport_parser' => (is => 'rw', isa => 'Travel::Search::Airport::Parser');
has 'depart_airport' => (is => 'rw', isa => 'ArrayRef[Travel::Data::Airport]');
has 'return_airport' => (is => 'rw', isa => 'ArrayRef[Travel::Data::Airport]');
has 'trip_class'     => (is => 'rw', isa => 'Str');
has 'trip_type'      => (is => 'rw', isa => 'Str');
has 'depart_date'    => (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'Default' });
has 'return_date'    => (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'Default' });
has 'pax_adult'      => (is => 'rw', isa => 'Int');
has 'pax_child'      => (is => 'rw', isa => 'Int');
has 'pax_infant'     => (is => 'rw', isa => 'Int');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;

    if ( !defined $self->data_str ) {
        croak 'You can not create empty token';
    }

    $self->tokens(Travel::Search::Tokens->new( data_str => $self->data_str ));
    $self->airport_parser(Travel::Search::Airport::Parser->new(tokens => $self->tokens, IP => $self->IP));
    
    return;
}

=head2 parse_input

Method invokes Airport Parser, Date parser, passenger parser, other parsers to
parse the various means from the given data string.

=cut

sub parse_input {
    my ($self)  = @_;
    
    my ($departure, $return)    = $self->airport_parser->parse_airport;
    $self->depart_airport($self->set_airport_value($departure));
    $self->return_airport($self->set_airport_value($return));
    
    my $trip_details    = Travel::Search::TripDetails::Parser->new(tokens => $self->tokens);
    $self->trip_class($trip_details->parse_trip_class);
    $self->trip_type($trip_details->parse_trip_type);

    $self->parse_travel_dates();
    
    my $trip_pax        = Travel::Search::Passenger::Parser->new(tokens => $self->tokens);
    my($adt, $chd, $inf)= $trip_pax->parse_passenger();
    
    $self->pax_adult($adt);
    $self->pax_child($chd);
    $self->pax_infant($inf);
    
    return;
}

=head2 set_airport_value

Method converts L<Travel::Database::Schema::Result::City> into light weight object of
L<Travel::Data::Airport>

=cut

sub set_airport_value {
    my ($self, $citydata) = @_;
    
    return if (ref($citydata) ne "ARRAY");
    my @airports;
    foreach my $result(@{ $citydata }){
        next if(ref($result) ne 'Travel::Database::Schema::Result::City');
        push(@airports, Travel::Data::Airport->new(
            'city_name'         => $result->city_name,
            'country_name'      => $result->country_name,
            'country_code'      => $result->country_code,
            'airport_name'      => $result->airport_name,
            'airport_code'      => $result->airport_code,
            'prov_state_name'   => $result->prov_name,
            'prov_state_code'   => $result->prov_code
        ));
    }
    return \@airports;
}

=head2 parse_travel_dates

Method invokes Date parser based on the return value it also adjust the Trip Type Value.

=cut

sub parse_travel_dates {
    my($self)    = @_;
    
    my $date_parser     = Travel::Search::Date::Parser->new(
                            tokens          => $self->tokens,
                            expected_count  => $self->get_expected_date_count
                        );
    my $travel_dates    = $date_parser->parse_travel_dates();
    my $dates_counter   = 0;
    try {
        $dates_counter  = scalar(@{$travel_dates});
    };
    if($dates_counter == 1){
        $self->depart_date($travel_dates->[0]->{ 'date' });
        if($self->trip_type eq 'Default' || $self->trip_type eq 'OneWay'){
            $self->trip_type('OneWay');
        }
    }
    elsif($dates_counter == 2){
        my $dates_in_order  = $self->are_dates_in_order($travel_dates);
        $self->depart_date($travel_dates->[0]->{ 'date' });
        if($dates_in_order){
            if($self->trip_type eq 'Default' || $self->trip_type eq 'RoundTrip'){
                $self->return_date($travel_dates->[1]->{ 'date' });
                $self->trip_type('RoundTrip');
            }
        }
        else {
            if($self->trip_type eq 'Default' || $self->trip_type eq 'OneWay'){
                $self->trip_type('OneWay');
            }
            else {
                $self->return_date($travel_dates->[1]->{ 'date' });
            }
        }
    }
    
    return ;
}

=head2 get_expected_date_count

get_expected_date_count returns the possible date counts to parse from the string.

=cut

sub get_expected_date_count {
    my($self)    = @_;
    
    given($self->trip_type) {
        when(/OneWay/)  {
            return 1;
        };
        when(/RoundTrip/ || /Default/)  {
            return 2;
        };
    };
    
    return;
}

=head2 are_dates_in_order

are_dates_in_order checks whether two dates in a given array are in asceding order or not.

=cut


sub are_dates_in_order {
    my($self, $dates)    = @_;
    
    my @travel_dates    = @{$dates};
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

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;