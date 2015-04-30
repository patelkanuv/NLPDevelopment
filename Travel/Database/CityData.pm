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

package Travel::Database::CityData;

=head1 NAME

Travel::Database::CityData

=head1 SYNOPSIS

    use Travel::Database::CityData;
    my $data        = Travel::Database::CityData->new();
    my $airport     = $data->match_by_airport_code();
    my $airport     = $data->match_by_city_name();


=head1 DESCRIPTION

Travel::Database::CityData is interface to perform various search on WorldAirportList Table.

=cut

use Moose;
use Data::Dumper;

use lib qw(../../);
use Travel::Database::DBConfig;
use Travel::Database::Schema::Result::City;

has 'schema'  => (is => 'rw', isa => 'Travel::Database::Schema');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;
    
    my $dbm     = Travel::Database::DBConfig->new; 
    $self->schema( $dbm->get_handle() );
    #$self->schema->storage->debug(1);
    
    return;
}

=head2 match_by_airport_code($code)

match_by_airport_code matches by airport code in table and returns matched rows.. 

=cut

sub match_by_airport_code {
    my ($self, $code)  = @_;
    
    my @all_airports = $self->schema->resultset('City')->search(
        {   'LOWER(airport_code)'   => lc($code) },
        {   'order_by'              => { '-desc' => 'operating' }}
    );
    
    return \@all_airports;
}

=head2 match_by_airport_name($name)

match_by_airport_name matches by city name in table and returns matched rows.. 

=cut

sub match_by_city_name {
    my ($self, $city)  = @_;
    
    my @all_airports = $self->schema->resultset('City')->search(
        {   'LOWER(city_name)'  => $city },
        {   'order_by'          => { '-desc' => 'operating' }}
    );
    
    return \@all_airports;
}

=head2 match_by_prove_state_name($code)

match_by_prove_state_name matches by province code or province name in table province_state and returns matched rows.. 

=cut

sub match_by_prove_state_name {
    my ($self, $state)  = @_;
    
    my @all_province = $self->schema->resultset('ProvinceState')->search(
        {   -or => ['LOWER(code)'  => $state, 'LOWER(prov_name)'    => $state  ]},
    );
    
    return [] if !defined $all_province[0];
    return $self->match_by_airport_code($all_province[0]->major_airport);
}

=head2 match_by_country_code($code)

match_by_country_code matches by country code in table and returns matched rows.. 

=cut

sub match_by_country_code {
    my ($self, $code)  = @_;
    
    my @all_airports = $self->schema->resultset('City')->search(
        {   -or => ['LOWER(country_code)'   => lc($code),
                    'LOWER(country_name)'   => lc($code)
                ],
            -and => ['capital_city'          => 'true'] },
        {   'order_by'          => { '-desc' => 'operating' }}
    );
    
    return \@all_airports;
}

=head2 match_by_city_name_and_country_code($city, $code)

match_by_city_name_and_country_code matches by country code and city name in table and returns matched rows.. 

=cut

sub match_by_city_name_and_country_code {
    my ($self, $city, $country)  = @_;
    
    $city =~ s/-/ /gx;
    my @all_airports = $self->schema->resultset('City')->search(
        {   'LOWER(city_name)'      => lc($city),
            'LOWER(country_code)'   => lc($country)
        },
        {   'order_by'              => { '-desc' => 'operating' }}
    );
    
    return \@all_airports;
}

=head2 match_by_city_name_and_airport_code($city, $code)

match_by_city_name_and_airport_code matches by airport code and city name in table and returns matched rows.. 

=cut

sub match_by_city_name_and_airport_code {
    my ($self, $city, $aiport_code)  = @_;
    
    $city =~ s/-/ /gx;
    my @all_airports = $self->schema->resultset('City')->search(
        {   'LOWER(city_name)'      => lc($city),
            'LOWER(airport_code)'   => lc($aiport_code)
        }
    );
    
    return \@all_airports;
}

sub match_by_city_name_like {
    my ($self, $city)  = @_;
    
    my @all_airports = $self->schema->resultset('City')->search(
        {
            -or => ['LOWER(airport_code)'   => lc($city),
                    'LOWER(city_name)'      => { 'like' => lc($city.'%') }
                ],
            -and => ['operating'            => 'true'],
        }
    );
    
    my @result;
    foreach my $record (@all_airports) {
        my %hash;
        $hash{ 'label' }    = $record->city_name.', '.$record->country_name.', '.$record->airport_name;
        $hash{ 'value' }    = $record->city_name.', '.$record->airport_code;
        push(@result, \%hash);
    }
    
    return \@result;
}

sub get_travel_keywords_like {
    my ($self, $word)   = @_;

    my @all_keywords    = $self->schema->resultset('TravelKeywords')->search(
        {
            'LOWER(word)'   => { like   => lc($word.'%')},
            'active'        => 'true'
        }
    );
    
    my @result;
    foreach my $record (@all_keywords) {
        my %hash;
        $hash{ 'label' }    = $record->word;
        $hash{ 'value' }    = $record->word;
        push(@result, \%hash);
    }
    
    return \@result;
}

sub get_nearest_airport_by_geo_location {
    my ($self, $latitude, $longitude, $country_code, $distance_within ) = @_;
  
    my $distance = '(SQRT( (POWER('
        .$latitude
        .'-(latitude*3.14/180), 2)+POWER(('
        .$longitude
        .'-(longitude*3.14/180))*COS('
        .$latitude
        .'+(latitude*3.14/180)/2), 2))))*6371';
                    
    my @airports  = $self->schema->resultset('City')->search({
        $distance               => { '<' => $distance_within },
        'LOWER(country_code)'   => lc($country_code),
        'operating'             => 'true'
    });
    
    return if(!scalar(@airports));
     
    my @airport = sort { 
                            $a->distance($latitude, $longitude) <=> $b->distance($latitude, $longitude)                       
                       } @airports;
    
    #foreach my $air (@airport) {
    #    print $air->airport_name, ", ",$air->airport_code,"\n";
    #}
    
    return $airport[0]->airport_code if defined $airport[0]->airport_code;
}
=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;