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

package Travel::Data::Config;

=head1 NAME

Travel::Data::Config contains various configuration required for Configurations.

=head1 SYNOPSIS

    use Travel::Data::Config qw(
        get_waitage_of_token
        get_waitage_of_tokens
        is_it_passenger_reference
        has_it_relative_reference
        month_to_number
        number_to_month
        weekday_to_number
        get_season_month
   );

=head1 DESCRIPTION

Travel::Data::Config is used for various utilities.

=cut

use base qw( Exporter );

use strict;
use warnings;

use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use Carp;
use Data::Dumper;

our @EXPORT_OK = qw(
                    get_waitage_of_token
                    get_waitage_of_tokens
                    is_it_passenger_reference
                    has_it_relative_reference
                    month_to_number
                    number_to_month
                    weekday_to_number
                    get_season_month
               );
               
my $passenger_weightage = {
        'adt'       => "1",
        'adult'     => "1",
        'adults'    => "2",
        'child'     => "1",
        'children'  => "2",
        'inf'       => "1",
        'infant'    => "1",
        'wife'      => "1",
        'husband'   => "1",
        'baby'      => "1",
        'kid'       => "1",
        'kids'      => "2",
        'family'    => "4",
        'friend'    => "1",
        'friends'   => "2",
        'babies'    => "2",
        'son'       => "1",
        'daughter'  => "1",
        'mother'    => "1",
        'father'    => "1",
        'brother'   => "1",
        'son'       => "1",
        'parents'   => "2",
        'pax'       => "1",
        'passener'  => "1",
        'passengers'=> "1",
        'i'         => "1",
        'we'        => "2",
        'you'       => "1",
        'he'        => "1",
        'she'       => "1",
        'it'        => "1",
        'they'      => "2",
        'me'        => '1'
};

my $passenger_reference = {
        'wife'      => "1",
        'husband'   => "1",
        'family'    => "1",
        'friend'    => "1",
        'friends'   => "1",
        'son'       => "1",
        'daughter'  => "1",
        'mother'    => "1",
        'father'    => "1",
        'brother'   => "1",
        'parents'   => "1",
        'i'         => "1",
        'we'        => "1",
        'you'       => "1",
        'he'        => "1",
        'she'       => "1",
        'it'        => "1",
        'they'      => "1",
        'me'        => '1'
};

my $weekday_to_number = {
        'monday'    => "1",
        'tuesday'   => "2",
        'wednesday' => "3",
        'thursday'  => "4",
        'friday'    => "5",
        'saturday'  => "6",
        'sunday'    => "7",
};

my $month_to_number = {
        'january'   => "1",
        'february'  => "2",
        'march'     => "3",
        'april'     => "4",
        'may'       => "5",
        'june'      => "6",
        'july'      => "7",
        'august'    => "8",
        'september' => "9",
        'october'   => "10",
        'november'  => "11",
        'december'  => "12",
};

my $number_to_month = {
        1   => 'january',
        2   => 'february',
        3   => 'march',
        4   => 'april',
        5   => 'may',
        6   => 'june',
        7   => 'july',
        8   => 'august',
        9   => 'september',
        10  => 'october',
        11  => 'november',
        12  => 'december',
};

my $season_month    = {
    'spring'    => {
                    start   => 3,
                    mid     => 4,
                    end     => 5
                },
    'summer'   => {
                    start   => 6,
                    mid     => 7,
                    end     => 8
                },
    'autumn'   => {
                    start   => 9,
                    mid     => 10,
                    end     => 11
                },
    'fall'      => {
                    start   => 9,
                    mid     => 10,
                    end     => 11
                },
    'winter'   => {
                    start   => 12,
                    mid     => 1,
                    end     => 2
                },
};

my $relative_reference = {
        'i'         => "me",
        'me'        => 'i'
};

=head1 METHODS

=head2 get_waitage_of_token

get_waitage_of_token returns the passenger waitage associated to passenger count to the token.
like we => represents 2 count, I => represents 1 count

=cut

sub get_waitage_of_token {
    my ($data)   = @_;
    
    my $weight  = 0;
    if($passenger_weightage->{$data}) {
        $weight += $passenger_weightage->{$data};
    }
    
    return $weight;
}

=head2 get_waitage_of_tokens

get_waitage_of_tokens returns the passenger waitage associated to passenger count to the list of tokens.
like we => represents 2 count, I => represents 1 count

=cut

sub get_waitage_of_tokens {
    my (@data)   = @_;
    
    my $weight  = 0;
    foreach my $data (@data) {
        if($passenger_weightage->{$data}) {
            $weight += $passenger_weightage->{$data};
        }
    }
    
    return $weight;
}

=head2 is_it_passenger_reference

is_it_passenger_reference returns the means of passenger 

=cut

sub is_it_passenger_reference {
    my ($data)  = @_;
    
    return $passenger_reference->{ $data };
}

=head2 has_it_relative_reference

has_it_relative_reference checks the similar meanings by another token, I == Me

=cut

sub has_it_relative_reference {
     my ($data)  = @_;
     
    return $relative_reference->{ $data };
}

=head2 month_to_number

month_to_number returns numeric value, Jan => 1, Feb => 2 ..., Dec => 12

=cut

sub month_to_number {
    my ($data)  = @_;
    
    return $month_to_number->{ $data };
}

=head2 number_to_month

number_to_month returns Month name, 1 => January, 2 => February ..., 12 => December

=cut

sub number_to_month {
    my ($data)  = @_;
    
    $data   += 0;
    return $number_to_month->{ $data };
}

=head2 weekday_to_number

weekday_to_number returns numeric value, Monday => 1, Tuesday => 2 .... Sunday => 7

=cut

sub weekday_to_number {
    my ($data)  = @_;
    
    return $weekday_to_number->{ $data };
}

=head2 get_season_month

get_season_month returns the month number for the season

=cut

sub get_season_month {
    my ($season, $phase)    = @_;
    
    $phase  = 'start' if !$phase;
    return $season_month->{ $season }{ $phase };
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;