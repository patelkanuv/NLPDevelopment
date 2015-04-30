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

package Travel::Air::Search::Query;

=head1 NAME

Travel::Air::Search::Query - is a format of Air search response query

=head1 SYNOPSIS

    use Travel::Air::Search::Query;
    my $query   = Travel::Air::Search::Query->new();
    $query->from_airport($self->parsed_data->depart_airport);
    $query->to_airport($self->parsed_data->return_airport);


=head1 DESCRIPTION

Travel::Air::Search::Query allows you to write data into its structure which can be used later on.

=cut

use Moose; # automatically turns on strict and warnings
use Data::Dumper;

use lib qw(../../../);
use Travel::Data::Airport;

=head1 ATTRIBUTES

=head2 from_airport ( rw / user supplied value )

Its array of L<Travel::Data::Airport>

=head2 to_airport ( rw / user supplied value )

Its array of L<Travel::Data::Airport>

=head2 depart_date ( rw / user supplied value )

departure journey date

=head2 return_date ( rw / user supplied value )

return journey date

=head2 adult ( rw / user supplied value )

Int value of passenger

=head2 child ( rw / user supplied value )

Int value of passenger

=head2 infant ( rw / user supplied value )

Int value of passenger

=head2 trip_class ( rw / user supplied value )

trip class of journey i.e Economy, Business Class, First Class

=head2 trip_type ( rw / user supplied value )

Trip Type value, i.e OneWay or RoundTrip

=cut

has 'from_airport'  => (is => 'rw', isa => 'ArrayRef[Travel::Data::Airport]');
has 'to_airport'    => (is => 'rw', isa => 'ArrayRef[Travel::Data::Airport]');
has 'depart_date'   => (is => 'rw', isa => 'Str');
has 'return_date'   => (is => 'rw', isa => 'Str');
has 'adult'         => (is => 'rw', isa => 'Int');
has 'child'         => (is => 'rw', isa => 'Int');
has 'infant'        => (is => 'rw', isa => 'Int');
has 'trip_class'    => (is => 'rw', isa => 'Str');
has 'trip_type'     => (is => 'rw', isa => 'Str');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub print_query {
    my ($self)  = @_;
    
    printf("%16s %s\n", 'From Airport :- ', Dumper $self->from_airport);
    printf("%16s %s\n", 'To Airport :- ', Dumper $self->to_airport);
    printf("%16s %s\n", 'Depart Date :- ', $self->depart_date);
    printf("%16s %s\n", 'Return Date :- ', $self->return_date);
    printf("%16s %s\n", 'Adult :- ', $self->adult);
    printf("%16s %s\n", 'Child :- ', $self->child);
    printf("%16s %s\n", 'Infant :- ', $self->infant);
    printf("%16s %s\n", 'Trip Type :- ', $self->trip_type);
    printf("%16s %s\n", 'Trip Class :- ', $self->trip_class);
    
    return;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut
1;