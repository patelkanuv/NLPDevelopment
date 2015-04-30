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

package Travel::Data::IPDetails;

=head1 NAME

Travel::Data::IPDetails performs Ip transformation checks, or may return nearest airport code for ip.

=head1 SYNOPSIS

    my $ip_details  = Travel::Data::IPDetails->new( IP => '41.41.56.164');
    print $ip_details->convert_ip_to_integer;

=head1 DESCRIPTION

Travel::Data::IPDetails returns the ip details for the given IP.

=cut

use Carp;
use Moose;
use Data::Dumper;
use Data::Validate::IP qw(is_ipv4 is_ipv6);

use lib qw(../../);
use Travel::Database::Schema;
use Travel::Database::DBConfig;

has 'IP'    => (is => 'rw', isa => 'Str', lazy => 1, default => sub { '1.1.1.1' });
has 'schema'=> (is => 'rw', isa => 'Travel::Database::Schema');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my $self = shift;

    my $dbm     = Travel::Database::DBConfig->new; 
    $self->schema( $dbm->get_handle() );
    #$self->schema->storage->debug(1);
    if(!is_ipv4($self->IP)) {
        croak "Invalid IP Address";
    }
    
    return ;
}

=head2 conevrt_ip_to_integer

convert_ip_to_integer converts Ip address to decimal value. 

=cut

sub convert_ip_to_integer {
    my ($self)  = @_;
    
    return unpack N => pack CCCC => split /\./x => $self->IP;
}

=head2 conevert_integer_to_ip

conevert_integer_to_ip converts decimal value to IP Address. 

=cut

sub convert_integer_to_ip {
    my ($self, $num)  = @_;
    
    return join '.', unpack 'C4', pack 'N', $num;
}

=head2 get_nearest_airport

get_nearest_airport returns the airport code for the IP address. 

=cut

sub get_nearest_airport {
    my ($self)  = @_;
    
    my $number = $self->convert_ip_to_integer;
    my @ip_block = $self->schema->resultset('GeoIPBlocks')->search(
        {
            'startipnum'    => { '<=' => $number},
            'endipnum'      => { '>=' => $number}
        }
    );
    
    my @all_airports = $self->schema->resultset('City')->search(
        {   'LOWER(airport_code)'  => lc($ip_block[0]->airport_code) }
    );
    
    return \@all_airports;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;