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

package Travel::Search::Passenger::Parser;

use Carp;
use Moose;
use Data::Dumper;
use Try::Tiny;
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";

use lib qw(../../../);
use Travel::Data::Config qw(
    get_waitage_of_token
    is_it_passenger_reference
    has_it_relative_reference
);

has 'pax_adult'     => (is => 'rw', isa => 'Int', lazy => 1, default => sub { 0 });
has 'pax_child'     => (is => 'rw', isa => 'Int', lazy => 1, default => sub { 0 });
has 'pax_infant'    => (is => 'rw', isa => 'Int', lazy => 1, default => sub { 0 });
has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');

sub parse_passenger {
    my ($self)  = @_;
    
    $self->parse_adult_pax();
    $self->parse_child_pax();
    $self->parse_infant_pax();
    $self->parse_indirect_pax_count();
    $self->parse_reference_token();
    
    return ($self->pax_adult, $self->pax_child, $self->pax_infant);
}

sub parse_adult_pax {
    my ($self)  = @_;
    
    foreach my $data (qw/adult adt adults pax passenger passengers ticket tickets/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            my $pax = $self->get_number_from_adjacent_token($token);
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_adult( $pax );
                $token->mark_token_used;
                $token->parsed_as('Passenger');
                return ;
            }
            else {
                $self->pax_adult( 1 );
                return ;
            }
        }
    }
    
    foreach my $data (qw/adult adt adults pax passenger passengers ticket tickets/) {
        foreach my $token (@{$self->tokens->get_tokens_byData_like($data)}) {
            my ($pax) = $token->data =~ /^(\d+)/x;
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_adult( $pax );
                $token->mark_token_used;
                $token->parsed_as('Passenger');
                return ;
            }
        }
    }
    
    return;
}

sub parse_child_pax {
    my ($self)  = @_;
    
    foreach my $data (qw/child children chd kid kids/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            my $pax = $self->get_number_from_adjacent_token($token);
            $token->mark_token_used;
            $token->parsed_as('Passenger');
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_child( $pax );
                return ;
            }
            else {
                $self->pax_child( 1 );
                return ;
            }
        }
    }
    
    foreach my $data (qw/child children chd kid kids/) {
        foreach my $token (@{$self->tokens->get_tokens_byData_like($data)}) {
            my ($pax) = $token->data =~ /^(\d+)/x;
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_child( $pax );
                $token->mark_token_used;
                $token->parsed_as('Passenger');
                return ;
            }
        }
    }
    
    return;
}

sub parse_infant_pax {
    my ($self)  = @_;
    
    foreach my $data (qw/infant infants inf baby babies/) {
        foreach my $token (@{$self->tokens->get_tokens_byData($data)}) {
            $token->mark_token_used;
            $token->parsed_as('Passenger');
            my $pax = $self->get_number_from_adjacent_token($token);
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_infant( $pax );
                return ;
            }
            else {
                $self->pax_infant( 1 );
                return ;
            }
        }
    }
    
    foreach my $data (qw/infant infants inf baby babies/) {
        foreach my $token (@{$self->tokens->get_tokens_byData_like($data)}) {
            my ($pax) = $token->data =~ /^(\d+)/x;
            if(defined $pax && $pax !~ /\D+/x) {
                $self->pax_infant( $pax );
                $token->mark_token_used;
                $token->parsed_as('Passenger');
                return ;
            }
        }
    }
    
    return;
}

sub parse_reference_token {
    my ($self)  = @_;
    
    my %hash;
    
    my $weight  = 0;
    foreach my $token ($self->tokens->get_tokens_byClass('Passenger')){
        $weight += get_waitage_of_token($token->data);
    }
    
    return if ($self->pax_infant + $self->pax_child + $self->pax_adult) >= $weight;
    
    my $relative_weight = 0;
    my $child_weight    = 0;
    
    foreach my $token ($self->tokens->get_tokens_byClass('Passenger')){
        next if !is_it_passenger_reference($token->data);
        next if $hash{ $token->data };
        
        $relative_weight    += get_waitage_of_token($token->data);
        $hash{ $token->data }= 1;
        if(defined has_it_relative_reference($token->data)){
            $hash{ has_it_relative_reference($token->data) }= 1;
        }
    }
    
    foreach my $key (keys %hash) {
        given($key) {
            when('i') {
                if($relative_weight > 2){
                    $relative_weight -= 1;
                }
            };
            when(/we/||/they/||/friends/||/parents/) {
                if($relative_weight == 3){
                    $relative_weight -= 1;
                }
                elsif($relative_weight >= 4) {
                    $relative_weight -= 2;
                }
            };
            when('family') {
                $relative_weight    = 4;
                $child_weight       = 2;
            };
        }
    }
    
    $relative_weight = ($relative_weight > 9) ? 9 : $relative_weight ;
    $relative_weight -= ($self->pax_infant + $self->pax_child + $self->pax_adult);
    #print $relative_weight, "\n";
    #print Dumper \%hash;
    
    if($relative_weight >= 1){
        $self->pax_adult($self->pax_adult + $relative_weight - $child_weight);
        $self->pax_child($self->pax_child + $child_weight);
    }
    
    return;
}

sub parse_indirect_pax_count {
    my ($self)  = @_;
    
    foreach my $token (@{$self->tokens->get_tokens_byData('for')}) {
        next if $token->is_used;
        try {
            my $next_token  = $self->tokens->get_next_token($token);
            my $next_data   = $self->tokens->get_two_next_token_data($token);
            next if $next_token->is_used;
            #next if !$next_token->has_number;

            if( $next_token->data !~ /\D+/x && $next_token->data <= 9) {
                $self->pax_adult($next_token->data);
                last;
            }            
            elsif($next_data eq 'party of') {
                try {
                    my $next_token1  = $self->tokens->get_next_token($next_token);
                    my $next_token2  = $self->tokens->get_next_token($next_token1);
                    next if $next_token2->is_used;
                    next if !$next_token2->has_number;
                    
                    if( $next_token2->data !~ /\D+/x && $next_token2->data <= 9) {
                        $self->pax_adult($next_token2->data);
                        $self->tokens->mark_two_next_token_data($token, 'Passenger');
                        $next_token2->token_parsed_as('Passenger');
                        
                        last;
                    }
                }
            }
        }
        catch {
            print STDERR $_;
        };
    }
    
    return ;
}

sub get_number_from_adjacent_token {
    my ($self, $token)  = @_;
    
    my $prev_token  = $self->tokens->get_prev_token($token);
    return  if(ref($prev_token) ne 'Travel::Search::Token');
    return if !$prev_token->has_number;
    $prev_token->mark_token_used;
    $prev_token->parsed_as('Passenger');
    return $prev_token->data;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;