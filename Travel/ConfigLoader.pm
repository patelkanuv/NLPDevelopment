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

package Travel::ConfigLoader;

=head1 NAME

Travel::ConfigLoader - Its config file parser. Can be used as interface or Moose role in your class.

=head1 SYNOPSIS

    extends 'Travel::ConfigLoader';
    my $config  = $self->get_config;

=head1 DESCRIPTION

This role can be inherited to imprt class specific configurations from Config file.

=cut

use Moose;
use Carp;
use Data::Dumper;
use Config::General;
use Cwd qw/abs_path getcwd/;
use lib qw(../);

=head1 ATTRIBUTES

=head2 config ( rw / auto generated )

config contains a hash of configuration.

=cut

has 'config'     => (is => 'rw', isa => 'HashRef');

sub BUILD {
    my ($self, $params) = @_;

    my $filename = get_config_path();
    my $conf    = Config::General->new($filename);
    my %config  = $conf->getall;

    $self->config(\%config);
    return ;
};

=head1 OBJECT METHODS

=head2 get_config

get_config returns the class specific configurations.

=cut

sub get_config  {
    my ($self)  = @_;
    
    my $cache   = $self->config();
    return $cache->{ ref($self) };
}

=head2 get_config_path

get_config_path checks for the config file in the directory and it will return
the first successful matching path to parse the file.

=cut

sub get_config_path {
    my @directories = split("/",getcwd());
    for(my $i = scalar(@directories); $i >= 1; $i--) {
        my $path = '';
        for(1..$i){
            next if !defined $directories[$_];
            $path   .= "/".$directories[$_];
        }
        $path .= "/test.conf";
        #print $path,"\n";
        if(-f $path){
            return $path;
        }
    }
    
    croak "Unable to open File";
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;