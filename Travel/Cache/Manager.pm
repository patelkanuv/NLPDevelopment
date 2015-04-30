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

package Travel::Cache::Manager;

=head1 NAME

Travel::Cache::Manager -Is a basic entity to NLP

=head1 SYNOPSIS

    use Travel::Cache::Manager;
    my $cache       = Travel::Cache::Manager->new();
    my $value       = $cache->read_cache($key);
    


=head1 DESCRIPTION

Its an interface to Cache::Memcached modules or any Memcached based module to communicate to,
its basic CRUD operation, Memcached Servers.

=cut

use Moose;
use Data::Dumper;
use Cache::Memcached;

use constant NO_REHASH          => 0;
use constant COMPRESS_THRESHOLD => 10_000;
use constant COMPRESS_RATIO     => 0.9;
use constant CONNECT_TIMEOUT    => 1.5;
use constant SELECT_TIMEOUT     => 2.0;

=head1 ATTRIBUTES

=head2 cache ( rw / built automatically )

cache is a object of L<Cache::Memcached>

=head2 expiry ( rw / built automatically )

default expiry time to set for the records

=head2 namespace ( rw / built automatically )

namespace is the word which will be append to all the keys

=cut

has 'cache'     => (is => 'rw', isa => 'Cache::Memcached');
has 'expiry'    => (is => 'rw', isa => 'Int',       lazy => 1, default => sub { 60 * 40 });
has 'namespace' => (is => 'rw', isa => 'Str',       lazy => 1, default => sub { 'Static:' });

use lib qw(../../);
with 'Travel::Cache::Basic';
extends 'Travel::ConfigLoader';

=head1 OBJECT METHODS

=head2 new

my $cache   = Travel::Cache::Manager->new( expiry => 30 * 24 * 60 * 60)

A contructor method, one or more arguement. Initilise attributes
and returns the self object.

=cut

sub BUILD {
    my ($self, $params) = @_;
    
    my $config  = $self->get_config;
    my $servers = (ref($config->{servers}) eq 'ARRAY') 
                ? $config->{servers}
                : [$config->{servers}]
                ;
                
    $self->cache(Cache::Memcached->new( {
                        'servers'               => $servers,
                        'no_rehash'             => NO_REHASH,
                        'compress_threshold'    => COMPRESS_THRESHOLD,
                        'compress_ratio'        => COMPRESS_RATIO,
                        'namespace'             => $self->namespace,
                        'connect_timeout'       => CONNECT_TIMEOUT,
                        'select_timeout'        => SELECT_TIMEOUT,
                    })
    );
    
    return ;
};

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;