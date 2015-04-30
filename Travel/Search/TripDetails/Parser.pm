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

package Travel::Search::TripDetails::Parser;

use Carp;
use Moose;
use Data::Dumper;
use Try::Tiny;

has 'trip_class'=> (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'Economy' });
has 'trip_type' => (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'Default' });
has 'tokens'    => (is => 'rw', isa => 'Travel::Search::Tokens');

sub parse_trip_class {
    my ($self)  = @_;
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('business')}) {
        if($token->data  eq 'businessclass') {
            $self->trip_class('Business Class');
            $token->mark_token_used;
            $token->parsed_as('Trip Class');
        }
        else {
            my $next_token  = $self->tokens->get_next_token($token);
            next if(ref($next_token) ne 'Travel::Search::Token');
            my $str = $token->data.$next_token->data;
            if($str  eq 'businessclass') {
                $self->trip_class('Business Class');
                $token->mark_token_used;
                $next_token->mark_token_used;
                $token->parsed_as('Trip Class');
                $next_token->parsed_as('Trip Class');
            }
        }
    }
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('firstclass')}) {
        if($token->data  eq 'firstclass') {
            $self->trip_class('First Class');
            $token->mark_token_used;
            $token->parsed_as('Trip Class');
        }
    }
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('1st')}) {
        my $next_token  = $self->tokens->get_next_token($token);
        next if(ref($next_token) ne 'Travel::Search::Token');
        my $str = $token->data.$next_token->data;
        if($str  eq '1stclass') {
            $self->trip_class('First Class');
            $token->mark_token_used;
            $next_token->mark_token_used;
            $token->parsed_as('Trip Class');
            $next_token->parsed_as('Trip Class');
        }

    }
    
    return $self->trip_class;
}

sub parse_trip_type {
    my ($self)  = @_;
    
    $self->parse_trip_type_oneway();
    $self->parse_trip_type_roundtrip();

    return $self->trip_type;
}

sub parse_trip_type_oneway {
    my ($self)  = @_;
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('oneway')}) {
        if($token->data  eq 'oneway') {
            $self->trip_type('OneWay');
            $token->mark_token_used;
            $token->parsed_as('Trip Type');
            return ;
        }
    }
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('1')}) {
        my $next_token  = $self->tokens->get_next_token($token);
        next if(ref($next_token) ne 'Travel::Search::Token');
        my $str = $token->data.$next_token->data;
        if($str  eq '1way') {
            $self->trip_type('OneWay');
            $token->mark_token_used;
            $next_token->mark_token_used;
            $token->parsed_as('Trip Type');
            $next_token->parsed_as('Trip Type');
            return ;
        }
    }
    
    foreach my $token (@{$self->tokens->get_tokens_byData_like('ow')}) {
        if($token->data  eq 'ow') {
            $self->trip_type('OneWay');
            $token->mark_token_used;
            $token->parsed_as('Trip Type');
            return ;
        }
    }
    
    return;
}

sub parse_trip_type_roundtrip {
    my ($self)  = @_;
    
    foreach my $data (qw/roundtrip rt returntrip return trip visit/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            $self->trip_type('RoundTrip');
            $token->mark_token_used;
            $token->parsed_as('Trip Type');
            return ;
        }
    }
    
    foreach my $data (qw/round return/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            my $next_token  = $self->tokens->get_next_token($token);
            next if(ref($next_token) ne 'Travel::Search::Token');
            if($token->data  eq 'trip') {
                $self->trip_type('RoundTrip');
                $token->mark_token_used;
                $next_token->mark_token_used;
                $token->parsed_as('Trip Type');
                $next_token->parsed_as('Trip Type');
                return ;
            }
        }
    }
    
    return ;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;