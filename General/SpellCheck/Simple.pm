package General::SpellCheck::Simple;

use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use Lingua::Ispell qw( :all );

sub BUILD {
    my $self = shift;

    #Lingua::Ispell::allow_compounds(1);
}

sub is_spell_correct {
    my ($self, $word)  = @_;
    
    my $lower_flag  = $self->_get_spell_check($word);
    my $uc_flag     = $self->_get_spell_check(ucfirst(lc($word)));
    if($lower_flag || $uc_flag) {
        return 1;
    }
    return 0;
}

sub _get_spell_check {
    my ($self, $word)  = @_;
    
    my $flag    = 1;
    for my $r ( spellcheck( $word ) ) {
        given($r->{'type'}){
            when('ok'){
                $flag   = 1;
            }
            when('root'){
                $flag   = 1;
            }
            when('guess'){
                $flag   = 1;
            }
            when('compound'){
                $flag   = 1;
            }
            when('none'){
                return 0;
            }
            when('miss'){
                return 0;
            }
        };
    }
    
    return $flag;
}

sub suggestions {
    my ($self, $word)  = @_;
    
    my @suggestions;
    for my $r ( spellcheck( $word ) ) {
        if ( $r->{'type'} eq 'miss' ) {
            my %hash    = ($r->{'term'}, $r->{'misses'});
            push(@suggestions, \%hash);
        }
    }
    
    return @suggestions;
}

sub add_word_dictionary {
    my ($self, $word)  = @_;
    
    return add_word($word);
}

sub add_word_dictionary_lc {
    my ($self, $word)  = @_;
    
    return add_word_lc($word);
}

1;
