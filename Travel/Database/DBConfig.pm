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

package Travel::Database::DBConfig;

=head1 NAME

Travel::Database::DBConfig -Is a basic entity to various datbase connection and configuration data.

=head1 SYNOPSIS

    use Travel::Database::DBConfig;
    my $config      = Travel::Database::DBConfig->new();
    my $db_obj      = $config->get_config();
    


=head1 DESCRIPTION

Provides ways to get cached or new database connection.

=cut

use base qw( Exporter );

use Moose;
use Carp;
use Data::Dumper;
use lib qw(../../);
use Travel::Database::Schema;

extends 'Travel::ConfigLoader';

=head1 ATTRIBUTES

=head2 default_db ( rw )

name of the default database to deal.

=head2 db_config ( rw )

various configurations.

=cut

has 'default_db' => (is => 'rw', isa => 'Str', lazy => 1, default => sub { 'NLPDevelopment' });
has 'db_config'  => (is => 'rw', isa => 'HashRef');

=head1 OBJECT METHODS

=head2 new

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my ($self, $params) = @_;
    
    my $config  = $self->get_config;
    $self->db_config($config);
    
    return ;
};

=head2 get_handle($dbname)

return the database connection handler object to interact with database. If $dbname is omitted then Default
database connection object will be returned. 

=cut

{
    my %handle_cache;

    sub get_handle {
        my ( $self, $key ) = @_;

        $key = $self->default_db if !defined $key;

        if (!exists $handle_cache{ $key }) {

            $handle_cache{ $key } = $self->db_config->{ $key }->{ 'schema' }->connect(
                $self->db_config->{ $key }->{ 'dsn' }, 
                $self->db_config->{ $key }->{ 'user' },
                $self->db_config->{ $key }->{ 'password' }
            ) or croak "Can't connect to DB: "; 
        }

        return $handle_cache{ $key };
    }
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;