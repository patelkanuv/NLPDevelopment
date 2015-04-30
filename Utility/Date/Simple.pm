package Utility::Date::Simple;

use v5.10;
use Carp;
use Moose;
use Try::Tiny;
use Data::Dumper;
use Date::Manip::Date;
use Date::Calc qw(Today Delta_Days Day_of_Week_to_Text Day_of_Week Add_Delta_Days);

sub get_next_day_from_today {
    my($self, $day)    = @_;
    
    return sprintf("%04d/%02d/%02d", Add_Delta_Days(Today, $day));
}

sub add_days_to_date {
    my($self, $date, $day)    = @_;
    
    my @date_part   = split(/\/|-/x, $date);
    return sprintf("%04d/%02d/%02d", Add_Delta_Days($date_part[0], $date_part[1], $date_part[2], $day));
}

sub get_date_from_sentence {
    my($self, $sentence)    = @_;
    
    my $date_parser = Date::Manip::Date->new();
    $date_parser->parse( $sentence );
    my @dates   = $date_parser->value;
    
    $date_parser->parse( 'today' );
    my @current   = $date_parser->value;
    
    if($dates[0] == $current[0] && $dates[1] < $current[1]){
        $dates[0]++;
    }
    
    return sprintf("%04d/%02d/%02d", $dates[0], $dates[1], $dates[2]);
}

sub autocomplete_day_in_date {
    my($self, $date)    = @_;
    
    my @cur_date    = Today();
    my @date_part   = split(/\/|-/x, $date);
    
    #current year == year and month == current month
    if( $date_part[0] == $cur_date[0] &&  $date_part[1] == $cur_date[1]) {
        $date_part[2] = $cur_date[2];
    }
    
    return sprintf("%04d/%02d/%02d", $date_part[0], $date_part[1], $date_part[2]);
}

sub get_date_from_month {
    my($self, $sentence)    = @_;
    
    return $self->autocomplete_day_in_date(
        $self->get_date_from_sentence($sentence)
    );
}

1;
