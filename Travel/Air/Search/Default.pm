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

package Travel::Air::Search::Default;

=head1 NAME

Travel::Air::Search::Default - Applies all possible Default values either general or client specific

=head1 SYNOPSIS

    use Travel::Air::Search::Default;
    my $token       = Travel::Air::Search::Default->new( parsed_data => $tokens);
    my $token       = $token->apply_default_params();

=head1 DESCRIPTION

Default class takes parsed data and applies possible default values to parsed data. Client specified values will take
precedence over the default value. If the client values are absence then general values will be used.

=cut

use Moose; # automatically turns on strict and warnings
use Data::Dumper;
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);

use constant DEFAULT_KEY    => 'general';

use lib qw(../../../);
use Travel::Error::Message;
use Travel::Air::Search::Query;

=head1 ATTRIBUTES

=head2 client ( rw / user supplied value )

Its name of client request the search

=head2 parsed_data ( rw / user supplied value )

parsed data that is object of L<Travel::Air::Search::Tokens::Parser>

=head2 warnings ( rw / built automatically )

Whenever any default value is used then warning message is generated.

=cut

has 'client'        => (is => 'rw', isa => 'Str', lazy  => 1, default   => sub { return DEFAULT_KEY });
has 'parsed_data'   => (is => 'rw', isa => 'Travel::Air::Search::Tokens::Parser');
has 'warnings'      => (is => 'rw', isa => 'ArrayRef[Travel::Error::Message]');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

my $default_data    = {
    general => {
        'trip_type' => 'RoundTrip',
        'pax'       => [1, 0, 0],
        'dep_date'  => 7,
        'ret_date'  => 3
    },
};

=head2 apply_default_params

apply_default_params will check the parsed value and if for optional field there
is no values are parsed then try to apply either client specific or general default values.

=cut

sub apply_default_params {
    my ($self)  = @_;
    
    my $query   = Travel::Air::Search::Query->new();
    
    #Trip Class
    $query->trip_class( $self->parsed_data->trip_class );
    #Depart Airport
    if(ref($self->parsed_data->depart_airport) eq 'ARRAY') {
        $query->from_airport($self->parsed_data->depart_airport);
    }
    #Destination Airport
    if(ref($self->parsed_data->return_airport) eq 'ARRAY') {
        $query->to_airport($self->parsed_data->return_airport);
    }
    #Trip Type
    if($self->parsed_data->trip_type eq 'Default') {
        $query->trip_type( $self->get_default_trip_type );
    }
    else {
        $query->trip_type( $self->parsed_data->trip_type);
    }
    #Depart Date
    if($self->parsed_data->depart_date eq 'Default') {
        $query->depart_date( $self->get_default_depart_date );
    }
    else {
        $query->depart_date( $self->parsed_data->depart_date);
    }
    #Return Date
    if($self->parsed_data->return_date eq 'Default' && $query->trip_type eq 'RoundTrip') {
        $query->return_date( $self->get_default_return_date($query->depart_date));
    }
    else {
        $query->return_date( $self->parsed_data->return_date);
    }
    #Adult passenger
    if($self->parsed_data->pax_adult == 0) {
        $query->adult( $self->get_default_adult_pax );
    }
    else {
        $query->adult( $self->parsed_data->pax_adult);
    }
    
    #Child passenger
    if($self->parsed_data->pax_child == 0) {
        $query->child( $self->get_default_child_pax );
    }
    else {
        $query->child( $self->parsed_data->pax_child);
    }
    
    #Infant passenger
    if($self->parsed_data->pax_infant == 0) {
        $query->infant( $self->get_default_infant_pax );
    }
    else {
        $query->infant( $self->parsed_data->pax_infant);
    }
    
    return $query;
}

=head2 get_default_trip_type

get_default_trip_type return a client specific trip type value, if client value is not available
then default trip_type value is returned.

=cut

sub get_default_trip_type {
    my($self)   = @_;
    
    $self->push_warnings('Default trip_type is used');
    my $key = ( $default_data->{ $self->client }{ 'trip_type' })
            ? $self->client
            : DEFAULT_KEY;
    return $default_data->{ $key }{ 'trip_type' }
}

=head2 get_default_adult_pax

get_default_adult_pax return a client specific trip adult pax count, if client value is not available
then default adult pax value is returned.

=cut

sub get_default_adult_pax {
    my($self)   = @_;
    
    $self->push_warnings("Default adult pax count is used");
    my $key = ( $default_data->{ $self->client }{ 'pax' })
            ? $self->client
            : DEFAULT_KEY;
    return $default_data->{ $key }{ 'pax' }->[0];
}

=head2 get_default_child_pax

get_default_child_pax return a client specific trip child pax count, if client value is not available
then default child pax value is returned.

=cut

sub get_default_child_pax {
    my($self)   = @_;
    
    my $key = ( $default_data->{ $self->client }{ 'pax' })
            ? $self->client
            : DEFAULT_KEY;
    return $default_data->{ $key }{ 'pax' }->[1];
}

=head2 get_default_infant_pax

get_default_infant_pax return a client specific trip infant pax count, if client value is not available
then default infant pax value is returned.

=cut

sub get_default_infant_pax {
    my($self)   = @_;
    
    my $key = ( $default_data->{ $self->client }{ 'pax' })
            ? $self->client
            : DEFAULT_KEY;
    return $default_data->{ $key }{ 'pax' }->[2];
}

=head2 get_default_depart_date

get_default_depart_date return a client specific trip depart_date, if client value is not available
then default depart_date value is returned.

=cut

sub get_default_depart_date {
    my($self)   = @_;
    
    $self->push_warnings("Default depart date is used");
    my $key = ( $default_data->{ $self->client }{ 'dep_date' })
            ? $self->client
            : DEFAULT_KEY;
    my $diff    = $default_data->{ $key }{ 'dep_date' };
    
    return sprintf("%04d/%02d/%02d", Add_Delta_Days(Today, $diff));
}

=head2 get_default_return_date

get_default_return_date return a client specific trip return_date, if client value is not available
then default return_date value is returned.

=cut

sub get_default_return_date {
    my($self, $date)   = @_;
    
    $self->push_warnings("Default return date is used");
    my $key = ( $default_data->{ $self->client }{ 'ret_date' })
            ? $self->client
            : DEFAULT_KEY;
    my $diff    = $default_data->{ $key }{ 'ret_date' };
    
    my @date    = split(/\//x, $date);
    return sprintf( "%04d/%02d/%02d",
                    Add_Delta_Days(
                          $date[0],
                          $date[1],
                          $date[2],
                          $diff
                        )
                    );
}

=head2 push_warnings

push_warnings function adds a message whenever there is a use of default value

=cut

sub push_warnings {
    my($self, $warning)    = @_;
    
    my $warn    = Travel::Error::Message->new();
    
    my $warnings    = $self->warnings;
    push(@{$warnings}, $warn->get_warning_message($warning));
    
    $self->warnings($warnings);
    
    return ;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;