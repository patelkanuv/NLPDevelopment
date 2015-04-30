package Travel::Search::Airport::SpellingCorrector;

use Carp;
use Moose;
use Data::Dumper;
use Try::Tiny;

use lib qw(../../../);
use Travel::Data::Airport;
use Travel::Cache::DataCenter;
use Travel::Database::Schema::Result::City;
use General::SpellCheck::Simple;

has 'tokens'        => (is => 'rw', isa => 'Travel::Search::Tokens');
has 'dictionary'    => (is => 'rw', isa => 'General::SpellCheck::Simple',
                        default   => sub { General::SpellCheck::Simple->new });
has 'datacenter'    => (is => 'rw', isa => 'Travel::Cache::DataCenter',
                        default => sub { Travel::Cache::DataCenter->new });

sub make_spell_correction {
    my($self)   = @_;
    
    $self->is_first_token_misspelled();
    $self->is_second_token_misspelled();
    $self->is_both_token_misspelled();
    
    return;
}

sub is_first_token_misspelled {
    my($self)   = @_;
    
    foreach my $token ($self->tokens->get_regular_misspelled_tokens) {
        next if $token->has_number;
        
        my ($next_token, $next_token_data) = $self->tokens->get_next_token_and_data($token);
        my @suggestions = $self->dictionary->suggestions($token->data);
        
        if(scalar(@suggestions) >= 1 ) {
            foreach my $new_city(@{$suggestions[0]->{ $token->data } }) {
                if ($self->_get_matching_airports($new_city, $next_token_data)) {
                    $token->replace_data(lc($new_city));
                }
                
            }
        }
    }
    
    return;
}

sub is_second_token_misspelled {
    my($self)   = @_;
    
    foreach my $token ($self->tokens->get_regular_misspelled_tokens) {
        next if $token->has_number;
        
        my ($prev_token, $prev_token_data) = $self->tokens->get_prev_token_and_data($token);
        my @suggestions = $self->dictionary->suggestions($token->data);
        
        if(scalar(@suggestions) >= 1 ) {
            foreach my $new_city(@{$suggestions[0]->{ $token->data } }) {
                if ($self->_get_matching_airports($prev_token_data, $new_city)) {
                    $token->replace_data(lc($new_city));
                }
                
            }
        }
    }
    
    return;
}

sub is_both_token_misspelled {
    my($self)   = @_;
    
    foreach my $token ($self->tokens->get_regular_misspelled_tokens) {
        next if $token->has_number;
        my ($next_token, $next_token_data) = $self->tokens->get_next_token_and_data($token);
        next if ref($next_token) ne 'Travel::Search::Token';
        next if $next_token->is_spell_correct;
        
        try {            
            my @token_suggestions = $self->dictionary->suggestions($token->data);
            my @next_token_suggestions = $self->dictionary->suggestions($next_token_data);
            
            if(scalar(@token_suggestions) >= 1  && scalar(@next_token_suggestions) >= 1) {
                foreach my $token_city(@{$token_suggestions[0]->{ $token->data } }) {
                    foreach my $next_token_city(@{$next_token_suggestions[0]->{ $next_token_data } }) {
                        if ($self->_get_matching_airports($token_city, $next_token_city)) {                            
                            $token->replace_data(lc($token_city));
                            $next_token->replace_data(lc($next_token_city));
                        }
                    }   
                }
            }
        };
    }
    
    return;
}

sub _get_matching_airports {
    my ($self, @tokens_data) = @_;

    my $city_name = join(" ", @tokens_data); 
    $city_name =~ s/-/ /gx;
    my $all_airports = $self->datacenter->match_by_city_name(lc($city_name));
    if(scalar(@{$all_airports}) >= 1) {
        return 1;
    }
    
    return 0;
}

1;