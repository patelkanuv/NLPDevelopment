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

package Travel::Cache::DataCenter;

=head1 NAME

Travel::Cache::DataCenter -Is an gateway to all the data required from the various source.

=head1 SYNOPSIS

    use Travel::Cache::DataCenter;
    my $data        = Travel::Cache::DataCenter->new();
    my $airport     = $data->get_nearest_airport('113.20.16.231');
    


=head1 DESCRIPTION

DataCenter is single communication point to various datasource like database, Cache or BerkleyDB.
It reads data from either Database or BerkleyDB and stores that into cache for the faster retrieval
if the same request is reapeated. 

=cut

use Moose;
use Data::Dumper;

use lib qw(../../);
use Travel::Cache::Manager;
use Travel::Database::CityData;
use Travel::IPList::IpToAirport;

=head1 ATTRIBUTES

=head2 manager ( rw / required field )

manager is the object of caching class L<Travel::Cache::Manager>.

=head2 na_ip_detail ( rw / user supplied value )

na_ip_detail is object of IP storage for North America and object of class <Travel::IPList::NorthAmerica::Store>

=head2 row_ip_detail ( rw / built automatically )

row_ip_detail is object of IP storage for whole world except North America and object of class <Travel::IPList::RestOfWorld::Store>

=head2 city_data ( rw / built automatically )

object of class <Travel::Database::CityData>

=cut

has 'manager'       => (is => 'rw', isa => 'Travel::Cache::Manager');
has 'city_data'     => (is => 'rw', isa => 'Travel::Database::CityData');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my ($self, $params) = @_;
    
    $self->manager(Travel::Cache::Manager->new( expiry => 30 * 24 * 60 * 60) );
    $self->city_data(Travel::Database::CityData->new);
    
    return ;
};

=head2 get_nearest_airport($ip);

It returns the airport code of the nearest airport to the given IP address. 

=cut

sub get_nearest_airport {
    my ($self, $ip) = @_;
    
    my $ip_details  = $self->manager->read_cache('IP_Details_'.$ip);
    if(!$ip_details) {
        my $ip_to_airport = Travel::IPList::IpToAirport->new('IP' => $ip);
        my $airport_code  = $ip_to_airport->get_nearest_airport();     
        if($airport_code) {
            $ip_details =$self->match_by_airport_code(lc($airport_code));
            $self->manager->store_cache('IP_Details_'.$ip, $ip_details);
        }  
    }
    
    return $ip_details;
}

=head2 match_by_airport_code($code);

match_by_airport_code will retrieve airport details from database or cache matching given airport code.

=cut

sub match_by_airport_code {
    my ($self, $code)  = @_;

    my $airport_details  = $self->manager->read_cache('Airport_Details_by_code_'.$code);
    if(!$airport_details) {
        $airport_details = $self->city_data->match_by_airport_code($code);
        $self->manager->store_cache('Airport_Details_by_code_'.$code, $airport_details);
    }

    return $airport_details;
}

=head2 match_by_city_name($city);

match_by_city_name will retrieve airport details from database or cache matching given city name.

=cut

sub match_by_city_name {
    my ($self, $city)  = @_;

    my $airport_details  = $self->manager->read_cache('Airport_Details_by_city_'.$city);
    if(!$airport_details) {
        $airport_details = $self->city_data->match_by_city_name($city);
        $self->manager->store_cache('Airport_Details_by_city_'.$city, $airport_details);
    }

    return $airport_details;
}

=head2 match_by_province_state_name($state);

match_by_province_state_name will retrieve airport details from database or cache matching given state/province code or name.

=cut

sub match_by_province_state_name {
    my ($self, $state)  = @_;

    my $airport_details  = $self->manager->read_cache('Airport_Details_by_prov_state_'.$state);
    if(!$airport_details) {
        $airport_details = $self->city_data->match_by_prove_state_name($state);
        $self->manager->store_cache('Airport_Details_by_prov_state_'.$state, $airport_details);
    }

    return $airport_details;
}

=head2 match_by_country_code($code);

match_by_country_code will retrieve airport details from database or cache matching given country code.

=cut

sub match_by_country_code {
    my ($self, $code)  = @_;

    my $airport_details  = $self->manager->read_cache('Airport_Details_by_country_code_'.$code);
    if(!$airport_details) {
        $airport_details = $self->city_data->match_by_country_code($code);
        $self->manager->store_cache('Airport_Details_by_country_code_'.$code, $airport_details);
    }

    return $airport_details;
}

=head2 match_by_city_name_and_country_code($city, $code);

match_by_city_name_and_country_code will retrieve airport details from database or cache matching given country code and city name.

=cut

sub match_by_city_name_and_country_code {
    my ($self, $city, $country)  = @_;
    
    my $airport_details = $self->manager->read_cache(
                            'Airport_Details_by_city_'.$city.'and_country_'.$country
                        );
    if(!$airport_details) {
        $airport_details= $self->city_data->match_by_city_name_and_country_code($city, $country);
        $self->manager->store_cache(
            'Airport_Details_by_city_'.$city.'and_country_'.$country,
            $airport_details
        );
    }

    return $airport_details;
}

=head2 match_by_city_name_and_airport_code($city, $code);

match_by_city_name_and_airport_code will retrieve airport details from database or cache matching given airport code and city name.

=cut

sub match_by_city_name_and_airport_code {
    my ($self, $city, $airport_code)  = @_;
    
    my $airport_details = $self->manager->read_cache(
                            'Airport_Details_by_city_'.$city.'and_airport_code_'.$airport_code
                        );
    if(!$airport_details) {
        $airport_details= $self->city_data->match_by_city_name_and_airport_code($city, $airport_code);
        $self->manager->store_cache(
            'Airport_Details_by_city_'.$city.'and_airport_code_'.$airport_code,
            $airport_details
        );
    }

    return $airport_details;
}

sub get_airport_city_like {
    my ($self, $city)  = @_;
    
    my $airport_details = $self->manager->read_cache(
                            'autocomplete_Airport_Details_by_city_'.$city
                        );
    
    if(!$airport_details) {
        $airport_details= $self->city_data->match_by_city_name_like($city);
        $self->manager->store_cache(
            'autocomplete_Airport_Details_by_city_'.$city,
            $airport_details
        );
    }
    
    return $airport_details;
}

sub get_travel_keywords_like {
    my ($self, $word)  = @_;
    
    my $keyword_details = $self->manager->read_cache(
                            'autocomplete_travel_keywords_by_word_'.$word
                        );
    
    if(!$keyword_details) {
        $keyword_details= $self->city_data->get_travel_keywords_like($word);
        $self->manager->store_cache(
            'autocomplete_travel_keywords_by_word_'.$word,
            $keyword_details
        );
    }
    
    return $keyword_details;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;