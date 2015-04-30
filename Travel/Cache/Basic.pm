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

package Travel::Cache::Basic;

=head1 NAME

Travel::Cache::Basic -Is an Interface to communicate to Caching server basic methods.

=head1 SYNOPSIS

    with Travel::Cache::Basic;
    
    $object->store_cache($key, $value, $time);
    $object->read_cache($key);
    $object->delete_cache($key);

=head1 DESCRIPTION

Its an interface to Cache::Memcached modules or any Memcached based module to communicate to,
its basic CRUD operation, Memcached Servers.

=cut

use Moose::Role;
use Data::Dumper;

requires qw(expiry cache);

=head1 OBJECT METHODS

=head2 store_cache($key, $vlaue, $expiry)

Store Cache stores the $value in memcached against $key. The expiration time is set to $expriy.
If $expiry was undef then default expiry time is used.

=cut

sub store_cache {
    my ($self, $key, $vlaue, $expiry)   = @_;
  
    $key    =~ s/\s+//xg;
    $expiry   = $self->expiry if (!defined $expiry || $expiry =~/\D+/x);
    return $self->cache->set($key, $vlaue, $expiry);
}

=head2 read_cache($key)

read Cache reads the $key in memcached and returns the read value.
If read value is not found then undef value is returned.

=cut

sub read_cache {
    my ($self, $key)   = @_;
    
    $key    =~ s/\s+//xg;
    return $self->cache->get($key);
}

=head2 delete_cache($key)

delete cache delete the value stored in memcached against the $key value.

=cut

sub delete_cache {
    my ($self, $key)   = @_;
    
    $key    =~ s/\s+//xg;
    return $self->cache->delete($key);
}

=head2 flush_cache

flush_cache deletes all the stored value in All the memcached servers in the given cluster.

=cut

sub flush_cache {
    my ($self)   = @_;
    
    return $self->cache->flush_all;
}

=head2 flush_connection

flush_connection will remove all the cached connections. Its important to use this when we are using Forks.

=cut

sub flush_connection {
    my ($self)   = @_;
    
    return $self->cache->disconnect_all;
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;