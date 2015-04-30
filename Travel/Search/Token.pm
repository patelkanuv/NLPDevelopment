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

package Travel::Search::Token;

=head1 NAME

Travel::Search::Token -Is a basic entity to NLP

=head1 SYNOPSIS

    use Travel::Search::Token;
    my $token       = Travel::Search::Token->new( data => 'London');
    my $class       = $token->class();
    


=head1 DESCRIPTION

Token is the basic entity to NLP. Tokens can be any word either it contains meaningful
content in the context of parsing or it would be basic english word which may not have
any meaning in the context parsing. Combining neighbour tokens may produce meaningful
info in some cases.

=cut


use Carp;
use Moose; # automatically turns on strict and warnings
use Data::Dumper;

use lib qw(../../);
use General::SpellCheck::Simple;
use Travel::Data::Dictionary qw( is_search_keywords convert_search_keywords);

=head1 ATTRIBUTES

=head2 data ( rw / required field )

Its word  token object contains.

=head2 original_data ( rw / replaced value )

Its keeps value of data attribute if that was changed due to any reason.

=head2 position ( rw / user supplied value )

Position number of the word in search string

=head2 has_number ( rw / built automatically )

set to true if data attribute contains any numeric value. Default value is 0

=head2 is_used ( rw / built automatically )

set to true if data attribute contains is used in parsing string. Default value is 0

=head2 class ( rw / built automatically )

What type of token data is i.e Indicators, Personal, Passenger etc. Default value is Regular

=head2 parsed_as ( rw / buiit automatically )

The data is parsed as may be Date, City/Airport, Passenger etc. Default value is None

=head2 is_spell_correct( rw / built automatically )

set to true if data attribute contains correct spell. Default value is 0

=head2 dictionary( rw / built automatically| user assigned )

Instatance of L<General::SpellCheck::Simple> 

=cut

has 'data'              => (is => 'rw', isa => 'Str', required  => 1);
has 'original_data'     => (is => 'rw', isa => 'Str');
has 'position'          => (is => 'rw', isa => 'Int', default   => sub { 1 });
has 'has_number'        => (is => 'rw', isa => 'Int', default   => sub { 0 });
has 'is_used'           => (is => 'rw', isa => 'Int', default   => sub { 0 });
has 'class'             => (is => 'rw', isa => 'Str', default   => sub { 'Regular' });
has 'parsed_as'         => (is => 'rw', isa => 'Str', default   => sub { 'None' });
has 'is_spell_correct'  => (is => 'rw', isa => 'Int', default   => sub { 0 });
has 'dictionary'        => (is => 'rw', isa => 'General::SpellCheck::Simple', default   => sub { General::SpellCheck::Simple->new });

with qw(MooseX::Clone);

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;

    if ( !defined $self->data ) {
        croak 'You can not create empty token';
    }

    if ($self->data =~ /\d/x) {
        $self->has_number(1);
    }
    #assign Class
    $self->class(is_search_keywords($self->data));
    #apply possible conversions
    if(is_search_keywords($self->data) eq 'Regular') {
        convert_search_keywords($self);
    }
    #spelling correction
    $self->is_spell_correct( $self->dictionary->is_spell_correct($self->data) );

    return ;
}

=head2 mark_token_used

Token is_used attribute is set to true, indicating this token is used once. 

=cut

sub mark_token_used {
    my ($self)  = @_;
    
    $self->is_used(1);
    return;
}

=head2 mark_token_unused

Token is_used attribute is set to false, indicating this token is available to extract means. 

=cut

sub mark_token_unused {
    my ($self)  = @_;
    
    $self->is_used(0);
    return;
}

=head2 replace_data($data)

replace data attribute with new value and shift old value in the original_data attribute. 

=cut

sub replace_data {
    my ($self, $data)  = @_;
    
    if(!$self->original_data) {
        $self->original_data($self->data);
    }
    $self->data($data);
    return;
}

sub token_parsed_as {
    my ($self, $str)  = @_;
    
    $self->mark_token_used;
    $self->parsed_as($str);
    return;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut
    
1;
