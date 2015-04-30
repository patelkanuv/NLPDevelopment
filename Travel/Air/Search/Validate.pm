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

package Travel::Air::Search::Validate;

=head1 NAME

Travel::Air::Search::Validate - applies all validation on finally generated data.

=head1 SYNOPSIS

    use Travel::Air::Search::Validate;
    my $token       = Travel::Air::Search::Validate->new( parsed_data => $tokens);
    my $result      = $token->apply_validations();

=head1 DESCRIPTION

This class applies all error checks on parsed data. If there is any error found then it will return as failed with
list of errors that were trapped.

=cut

use Moose; # automatically turns on strict and warnings
use Try::Tiny;
use DateTime;
use Data::Dumper;
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);

use constant DEFAULT_KEY    => 'general';

use lib qw(../../../);
use Travel::Error::Message;
use Travel::Air::Search::Default;

=head1 ATTRIBUTES

=head2 client ( rw / user supplied value )

Its name of client request the search

=head2 parsed_data ( rw / user supplied value )

parsed data that is object of L<Travel::Air::Search::Tokens::Parser>

=head2 errors ( rw / built automatically )

errors is list of L<Travel::Error::Message> for indetified values.

=cut

has 'client'        => (is => 'rw', isa => 'Str', lazy  => 1, default   => sub { return DEFAULT_KEY });
has 'parsed_data'   => (is => 'rw', isa => 'Travel::Air::Search::Tokens::Parser');
has 'success'       => (is => 'rw', isa => 'Str', lazy  => 1, default   => sub { return 'true'});
has 'errors'        => (is => 'rw', isa => 'ArrayRef[Travel::Error::Message]');
=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

=head2 apply_validations

apply_validations applies all the validation check, prepares the final result and returns the same to caller.

=cut

sub apply_validations {
    my($self)   = @_;
    
    my $query   = Travel::Air::Search::Default->new(
                    parsed_data => $self->parsed_data,
    );
    
    my $new_query   = $query->apply_default_params;
    
    $self->validate_query($new_query);
    
    my $result = {
        'query'     => $new_query,
        'success'   => $self->success,
        #'warnings'  => $query->warnings
    };
    
    if($self->success eq 'false') {
        $result->{'errors' } = $self->errors;
    }
    
    return $result;
}

=head2 validate_query

validate_query function validates data of L<Travel::Air::Search::Query>

=cut

sub validate_query {
    my($self, $new_query)   = @_;
    
    if(ref($new_query->from_airport) ne 'ARRAY') {
        $self->push_error('Unable to parse Departure City');
    }
    
    if(ref($new_query->to_airport) ne 'ARRAY') {
        $self->push_error('Unable to parse Destination City');
    }
    
    if(($new_query->adult + $new_query->child + $new_query->infant) > 9) {
        $self->push_error('Passenger count should be less than or equal to 9');
    }
    try {
        if(scalar(@{$new_query->from_airport}) == 1
        && scalar(@{$new_query->to_airport}) == 1
        && $new_query->from_airport->[0]->airport_code eq $new_query->to_airport->[0]->airport_code) {
            $self->push_error('Departure and Destination should not be same');
        }
    };
    
    if($new_query->trip_type eq 'RoundTrip') {
        my @dep_date    = split(/-|\.|\//x, $new_query->depart_date);
        my @ret_date    = split(/-|\.|\//x, $new_query->return_date);
        
        my $dd  = Delta_Days(
                    $dep_date[0], $dep_date[1], $dep_date[2],
                    $ret_date[0], $ret_date[1], $ret_date[2]
                );
        if($dd < 0){
            $self->push_error('Travel Dates are not in order');
        }
    }
    
    return ;
}

=head2 push_error

push_error function adds a message whenever there is an error trapped.

=cut

sub push_error {
    my($self, $error)    = @_;
    
    my $err_msg = Travel::Error::Message->new();
    
    my $errors  = $self->errors;
    push(@{$errors}, $err_msg->get_error_message($error));
    
    $self->errors($errors);
    $self->success('false');
    
    return;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;