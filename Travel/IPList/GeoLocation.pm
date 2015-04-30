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

package Travel::IPList::GeoLocation;

use Moose;
use Geo::IP;
use Data::Dumper;

has 'IP'    => (is => 'rw', isa => 'Str', lazy => 1, default => sub { '1.1.1.1' });
has 'GeoDB' => (is => 'ro', isa => 'Geo::IP', lazy => 1,
                default => sub { Geo::IP->open("/usr/share/GeoIP/GeoLiteCity.dat", GEOIP_STANDARD) });
    
sub geo_co_ordinates {
    my ($self) = @_;
    
    my $record = $self->_get_geo_record;
    return ($record->latitude, $record->longitude); 
}

sub geo_record {
    my ($self) = @_;
    
    return $self->_get_geo_record;
}

sub geo_co_ordinates_and_country {
    my ($self) = @_;
    
    my $record = $self->_get_geo_record;
    return ($record->latitude, $record->longitude, $record->country_code);
}

sub _get_geo_record {
    my ($self) = @_;
    
    return $self->GeoDB->record_by_addr($self->IP);
}
1;