#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use lib qw(../);
use General::SpellCheck::Simple;
use Travel::Database::DBConfig;

#add City Names to Dictionary
my $check   = General::SpellCheck::Simple->new();
my $dbm     = Travel::Database::DBConfig->new;
my $schema  = $dbm->get_handle();

my $cnt = 1;
my @all_airports    = $schema->resultset('City')->all;
foreach my $airport_city (@all_airports) {
    add_word_to_dictionary(lc($airport_city->city_name));
}

my @all_state_prov    = $schema->resultset('ProvinceState')->all;
#add province names in dictionary
foreach my $state_prov (@all_state_prov) {
    add_word_to_dictionary(lc($state_prov->prov_name));
}

sub add_word_to_dictionary {
    my $word = shift;
    if(!$check->is_spell_correct($word) ) {
        print $cnt++, ") ", $word, "\n";
        if ($word =~ /\s/) {
            foreach my $new_word(split(" ", $word)) {
                $check->add_word_dictionary($new_word);
            }
            return;
        }
        $check->add_word_dictionary($word);
    }
    return;
}
