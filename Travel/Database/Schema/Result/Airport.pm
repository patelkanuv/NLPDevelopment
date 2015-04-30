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

package Travel::Database::Schema::Result::Airport;

=head1 NAME

Travel::Database::Schema::Result::Airport - Is a basic class for airport_additional_info table.

=cut

use Moose;
use namespace::autoclean;
extends qw/DBIx::Class::Core/;

__PACKAGE__->load_components("InflateColumn::DateTime");
__PACKAGE__->table('airport_additional_info');
__PACKAGE__->add_columns(
    id => { 
        data_type     => 'integer',
        is_nullable   => 0,
        is_auto_increment => 1,
    },
    airport_name    => {
        data_type   => 'varchar',                     
    },
    country_name    => {
        data_type   => 'varchar',  
    },
    country_code    => {
        data_type   => 'varchar',
        size        => 2
    },
    city       => {
        data_type   => 'varchar',
    },
    airport_code    => {
        data_type   => 'varchar',
    },
    runway_length   => {
        data_type   => 'varchar',
    },
    runway_elevation=> {
        data_type   => 'varchar',
    },
    longitude       => {
        data_type   => 'varchar'
    },
    latitude        => {
        data_type   => 'varchar'
    },
    world_area_code        => {
        data_type   => 'integer'
    },
    email           => {
        data_type   => 'varchar',
    },
    telephone       => {
        data_type   => 'varchar'
    },
    fax             => {
        data_type   => 'varchar'
    },
    gmt_offset      => {
        data_type   => 'varchar'
    }
);
                            
__PACKAGE__->set_primary_key('id');

sub distance {
    my ($self ,$latitude, $longitude) = @_;  
   
    my $latitude_col  = $self->latitude*3.14/180;
    my $longitude_col = $self->longitude*3.14/180;
    
    my $x = $latitude - $latitude_col;
    my $y = ($longitude - $longitude_col)*cos(($latitude + $latitude_col)/2);
    
    return sqrt($x * $x + $y * $y) * 6371;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;