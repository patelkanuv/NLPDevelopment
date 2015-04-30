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

package Travel::IPList::IpToAirport;

use Moose;
use Data::Dumper;

use lib qw(../../);
use Travel::IPList::GeoLocation;
use Travel::Database::CityData;

has 'IP'        => (is => 'rw', isa => 'Str', lazy => 1, default => sub { '1.1.1.1' });
has 'city_data' => (is => 'rw', isa => 'Travel::Database::CityData');

sub BUILD {
    my ($self, $params) = @_;

    $self->city_data(Travel::Database::CityData->new);    
    return ;
};

sub get_nearest_airport {
    my ( $self) = @_;
    
    my $geoLocation = Travel::IPList::GeoLocation->new('IP' => $self->IP);
    my ($latitude, $longitude, $country_code ) = $geoLocation->geo_co_ordinates_and_country();
    return $self->find_nearest_airport($latitude, $longitude, $country_code);
}

sub find_nearest_airport {
    my ( $self, $latitude, $longitude, $country_code ) = @_;
    
    ($latitude, $longitude) = $self->convert_geo_co_ordinates_to_distance($latitude, $longitude);
    my @distances = (50, 100, 200, 500, 1000, 1500, 2000, 2500, 3000);
    
    foreach my $distance (@distances) {
        my $airport = $self->city_data->get_nearest_airport_by_geo_location(
                                            $latitude, $longitude, $country_code, $distance
                                        );
        return $airport if defined $airport;
    }
    return undef;
}

sub convert_geo_co_ordinates_to_distance {
    my ($self, $latitude, $longitude ) = @_;  
   
    $latitude  = $latitude  * 3.14 / 180;
    $longitude = $longitude * 3.14 / 180;
    
    return  $latitude, $longitude;
}

1;