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

package Travel::Error::Message;

=head1 NAME

Travel::Error::Message - a class to represent standard Error/Warning messages generated at any stage.

=head1 SYNOPSIS

    use Travel::Error::Message;
    my $message      = Travel::Error::Message->new();
    my $error        = $message->get_error_message('Unauthenticate usage of application');
    my $warning      = $message->get_warning_message('Default trip_type is used');


=head1 DESCRIPTION

Message class to represent standard Error/Warning messages generated at any stage, It convert message into
a object with its own Error code/Warning code. 

=cut

use Moose; # automatically turns on strict and warnings
use Data::Dumper;

=head1 ATTRIBUTES

=head2 code ( rw )

Error or Warning code.

=head2 message ( rw )

Message string.

=cut

has 'code'  => (is => 'rw', isa => 'Str');
has 'msg'   => (is => 'rw', isa => 'Str');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

my $error_keys  ={
    #Fatal Errors
    1   => {
        101 => 'Unauthenticate usage of application',
        102 => 'Invalid usage of application',
        103 => 'Access denied',
        104 => 'You have reached your daily access limit'
    },
    
    #Missing Input Data
    2   => {
        101 => 'No String to parse',
        102 => 'No client key',
        103 => 'Invalid client key',
        104 => 'Invalid Ip address',
    },
    
    #Missing Output Data or Invalid Output Data
    3   => {
        101 => 'Unable to parse Departure City',
        102 => 'Unable to parse Destination City',
        103 => 'Travel Dates are not in order',
        104 => 'Passenger count should be less than or equal to 9',
        105 => 'Departure and Destination should not be same',
    },
    
    #Unknown Errors
    4   => {
        101 => 'Unknown Error'
    },
    
    #Warnings
    5   => {
        999 => 'Unknown warning',
        101 => 'Default trip_type is used',
        102 => 'Default adult pax count is used',
        103 => 'Default depart date is used',
        104 => 'Default return date is used'
    },
};

=head2 get_error_message($msg)

generates error code for the given $msg and binds both of them with object. If error msg is unknown then
default error message is generated. 

=cut

sub get_error_message {
    my ($self, $msg)  = @_;
    
    foreach my $key1 (qw(1 2 3 4)) {
        foreach my $key2 (keys %{ $error_keys->{ $key1 }}) {
            if(lc($msg) eq lc( $error_keys->{ $key1 }{ $key2 })){
                $self->code(join(".", $key1, $key2));
                $self->msg($msg);
                return $self;
            }
        }
    }
    
    $self->code('4.101');
    $self->msg('Unknown Error');
    return $self;
}

=head2 get_warning_message($msg)

generates warning code for the given $msg and binds both of them with object. If warning msg is unknown then
default warning message is generated. 

=cut

sub get_warning_message {
    my ($self, $msg)  = @_;
    
    foreach my $key1 (qw(5)) {
        foreach my $key2 (keys %{ $error_keys->{ $key1 }}) {
            if(lc($msg) eq lc( $error_keys->{ $key1 }{ $key2 })){
                $self->code(join(".", $key1, $key2));
                $self->msg($msg);
                return $self;
            }
        }
    }
    
    $self->code('5.999');
    $self->msg('Unknown Warning');
    return $self;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;