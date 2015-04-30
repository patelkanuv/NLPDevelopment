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

package Travel::Data::Airport;

=head1 SYNOPSIS

    use Travel::Data::Airport;
    my $airport = Travel::Data::Airport->new(
        'city_name'         => $result->city_name,
        'country_name'      => $result->country_name,
        'country_code'      => $result->country_code,
        'airport_name'      => $result->airport_name,
        'airport_code'      => $result->airport_code,
        'prov_state_name'   => $result->prov_name,
        'prov_state_code'   => $result->prov_code
    );
    my $city    = $airport->city_name();

=head1 DESCRIPTION

Travel::Data::Airport is simple class to represent Airport Details.

=cut

use Moose; # automatically turns on strict and warnings

=head1 ATTRIBUTES

=head2 city_name ( rw / user supplied value )

Attribute contains city name.

=head2 country_name ( rw / user supplied value )

Attribute contains country name.

=head2 country_code ( rw / user supplied value)

Attribute contains country code.

=head2 airport_name ( rw / user supplied value )

Attribute contains airport name.

=head2 airport_code ( rw / user supplied value )

Attribute contains airport code.

=head2 prov_state_name ( rw / user supplied value )

Attribute contains province/state name.

=head2 prov_state_code ( rw / user supplied value )

Attribute contains province/state code.

=cut

has 'city_name'         => (is => 'rw', isa => 'Str');
has 'country_name'      => (is => 'rw', isa => 'Any');
has 'country_code'      => (is => 'rw', isa => 'Any');
has 'airport_name'      => (is => 'rw', isa => 'Any');
has 'airport_code'      => (is => 'rw', isa => 'Str');
has 'prov_state_name'   => (is => 'rw', isa => 'Any', lazy => 1, default => sub { '' });
has 'prov_state_code'   => (is => 'rw', isa => 'Any', lazy => 1, default => sub { '' });

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;