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

package Travel::IPList::RestOfWorld::Store;

=head1 NAME

Travel::IPList::RestOfWorld::Store -Is a basic entity to Rest of the world Ip store.

=head1 SYNOPSIS

    use Travel::IPList::RestOfWorld::Store;
    my $cache       = Travel::IPList::RestOfWorld::Store->new();
    my $value       = $cache->select($key);
    


=head1 DESCRIPTION

Its an interface to BerkeleyDB::Btree store for the IP to Airport relationship.

=cut

use Moose;
use Data::Dumper;
use BerkeleyDB;

extends 'Travel::ConfigLoader';

has 'database'  => (is => 'rw', isa => 'BerkeleyDB::Btree');

use lib qw(../ );
with 'Travel::IPList::Basic';

=head2 new


A constructor method, no arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my ($self, $params) = @_;
    
    my $config  = $self->get_config;
    my $env     = BerkeleyDB::Env->new (
        -Home       => $config->{ 'IPStore' }{ 'path' },
        -Flags      => DB_CREATE | DB_INIT_CDB | DB_INIT_MPOOL
    ) or die "cannot open environment: $BerkeleyDB::Error\n";
    
    my $db  = BerkeleyDB::Btree->new (
        -Filename   => "IP_and_airport_code.db", 
        -Flags      => DB_CREATE,
        -Env        => $env
    ) or die "couldn't create: $!, $BerkeleyDB::Error.\n";
    
    $self->database($db);
    
    return ;
};

1;
=head1 SEE ALSO

L<Travel::IPList::Basic>

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut