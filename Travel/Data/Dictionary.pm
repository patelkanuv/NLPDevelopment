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

package Travel::Data::Dictionary;

=head1 NAME

Travel::Data::Dictionary contains various dictionary usage, transforms data into specific language.

=head1 SYNOPSIS

    use Travel::Data::Dictionary qw(
        is_search_keywords
        convert_search_keywords 
        is_this_city_in_more_than_one_country
        is_this_word_start_of_cityname
        is_this_word_calendar_abbreviation
        is_this_word_three_letter_verb
        get_class_of_word
        invalid_province_to_use
   );

=head1 DESCRIPTION

Travel::Data::Dictionary contains various dictionary usage, transforms data into specific language.

=cut

use base qw( Exporter );

use strict;
use warnings;
use v5.14;
#use feature "lexical_subs";
#    no if $] >= 5.018, warnings => "experimental::smartmatch";
#    no if $] >= 5.018, warnings => "experimental::lexical_subs";
    
use Carp;
use Data::Dumper;

our @EXPORT_OK = qw(is_search_keywords
                    convert_search_keywords 
                    is_this_city_in_more_than_one_country
                    is_this_word_start_of_cityname
                    is_this_word_calendar_abbreviation
                    is_this_word_three_letter_verb
                    get_class_of_word
                    invalid_province_to_use
               );

{
    my %numbers   = (
        'one'       => 1,
        'two'       => 2,
        'three'     => 3,
        'four'      => 4,
        'five'      => 5,
        'six'       => 6,
        'seven'     => 7,
        'eight'     => 8,
        'nine'      => 9,
        'ten'       => 10,
        'eleven'    => 11,
        'twelve'    => 12,
        'thirteen'  => 13,
        'fourteen'  => 14,
        'fifteen'   => 15,
        'sixteen'   => 16,
        'seventeen' => 17,
        'eighteen'  => 18,
        'nineteen'  => 19,
        'twenty'    => 20,
        'first'     => '1st',
        'second'    => '2nd',
        'third'     => '3rd',
        'fourth'    => '4th',
        'fifth'     => '5th',
        'sixth'     => '6th',
        'seventh'   => '7th',
        'eighth'    => '8th',
        'nineth'    => '9th',
        'tenth'     => '10th',
    );
    
    my %months   = (
        'january'   => "MonthName",
        'february'  => "MonthName",
        'march'     => "MonthName",
        'april'     => "MonthName",
        'may'       => "MonthName",
        'june'      => "MonthName",
        'july'      => "MonthName",
        'august'    => "MonthName",
        'september' => "MonthName",
        'october'   => "MonthName",
        'november'  => "MonthName",
        'december'  => "MonthName",
    );
    
    my %week_days   = (
        'monday'    => "DayName",
        'tuesday'   => "DayName",
        'wednesday' => "DayName",
        'thursday'  => "DayName",
        'friday'    => "DayName",
        'saturday'  => "DayName",
        'sunday'    => "DayName"
    );
     
    my %key_words   = ( 
        'air'       => "Travel",
        'book'      => "Travel",
        'best'      => "Travel",
        'want'      => "Travel",
        'ticket'    => "Travel",
        'travel'    => "Travel",
        'trip'      => "Travel",
        'cheap'     => "Travel",
        'flight'    => "Travel",
        'flights'   => "Travel",
        'fare'      => "Travel",
        'price'     => "Travel",
        'round'     => "Travel",
        'journey'   => "Travel",
        
        'oneway'    => "TripType",
        'rt'        => "TripType",
        'ow'        => "TripType",
        'roundtrip' => "TripType",
        
        'to'        => "Location",
        'from'      => "Location",
        'departure' => "Location",
        'depart'    => "Location",
        'return'    => "Location",
        'departs'   => "Location",
        'returns'   => "Location",
        'departing' => "Location",
        'returning' => "Location",
        
        'today'     => "DayIndicator",
        'tommorrow' => "DayIndicator",
        'week'      => "DayIndicator",
        'weekend'   => "DayIndicator",
        'day'       => "DayIndicator",
        'days'      => "DayIndicator",
        'night'     => "DayIndicator",
        'nights'    => "DayIndicator",
        
        'summer'    => "Season",
        'winter'    => "Season",
        'fall'      => "Season",
        'spring'    => "Season",
        'autumn'    => "Season",
        
        'adt'       => "Passenger",
        'adult'     => "Passenger",
        'adults'    => "Passenger",
        'child'     => "Passenger",
        'children'  => "Passenger",
        'inf'       => "Passenger",
        'infant'    => "Passenger",
        'wife'      => "Passenger",
        'husband'   => "Passenger",
        'baby'      => "Passenger",
        'kid'       => "Passenger",
        'kids'      => "Passenger",
        'family'    => "Passenger",
        'friend'    => "Passenger",
        'friends'   => "Passenger",
        'babies'    => "Passenger",
        'son'       => "Passenger",
        'daughter'  => "Passenger",
        'mother'    => "Passenger",
        'father'    => "Passenger",
        'brother'   => "Passenger",
        'son'       => "Passenger",
        'parents'   => "Passenger",
        'people'    => "Passenger",
        'pax'       => "Passenger",
        'passenger' => "Passenger",
        'passengers'=> "Passenger",
        'i'         => "Passenger",
        'we'        => "Passenger",
        'you'       => "Passenger",
        'he'        => "Passenger",
        'she'       => "Passenger",
        'it'        => "Passenger",
        'they'      => "Passenger",
        'me'        => "Passenger",
        
        'next'      => "Indicators",
        'with'      => "Indicators",
        'this'      => "Indicators",
        'in'        => "Indicators",
        'at'        => "Indicators",
        'on'        => "Indicators",
        'in'        => "Indicators",
        'after'     => "Indicators",
        'of'        => "Indicators",
        'mid'       => "Indicators",
        'last'      => "Indicators",
        'for'       => "Indicators",
    
        'my'        => "Personal",
        'us'        => "Personal",
        'our'       => "Personal",
        'your'      => "Personal",
        'his'       => "Personal",
        'her'       => "Personal",
        'its'       => "Personal",
        'their'     => "Personal",
        'mine'      => "Personal",
        'myself'    => "Personal",
        'ourself'   => "Personal",
        
        'a'         => 'BasicEnglish',
        'an'        => 'BasicEnglish',
        'the'       => 'BasicEnglish',
        'and'       => 'BasicEnglish',
        'or'        => 'BasicEnglish',
        'is'        => 'BasicEnglish',
        'are'       => 'BasicEnglish',
        'has'       => 'BasicEnglish',
        'have'      => 'BasicEnglish',
        'was'       => 'BasicEnglish',
        'be'        => 'BasicEnglish',
        'had'       => 'BasicEnglish',
        'were'      => 'BasicEnglish',
        'by'        => 'BasicEnglish',
        'but'       => 'BasicEnglish',
        'not'       => 'BasicEnglish',
        'what'      => 'BasicEnglish',
        'all'       => 'BasicEnglish',
        'when'      => 'BasicEnglish',
        'can'       => 'BasicEnglish',
        'there'     => 'BasicEnglish',
        'each'      => 'BasicEnglish',
        'which'     => 'BasicEnglish',
        'do'        => 'BasicEnglish',
        'how'       => 'BasicEnglish',
        'if'        => 'BasicEnglish',
        'will'      => 'BasicEnglish',
        'up'        => 'BasicEnglish',
        'other'     => 'BasicEnglish',
        'about'     => 'BasicEnglish',
        'out'       => 'BasicEnglish',
        'many'      => 'BasicEnglish',
        'then'      => 'BasicEnglish',
        'these'     => 'BasicEnglish',
        'so'        => 'BasicEnglish',
        'some'      => 'BasicEnglish',
        'would'     => 'BasicEnglish',
        'make'      => 'BasicEnglish',
        'like'      => 'BasicEnglish',
        'into'      => 'BasicEnglish',
        'time'      => 'BasicEnglish',
        'more'      => 'BasicEnglish',
        'could'     => 'BasicEnglish',
        'than'      => 'BasicEnglish',
        'been'      => 'BasicEnglish',
        'who'       => 'BasicEnglish',
        'what'      => 'BasicEnglish',
        'am'        => 'BasicEnglish',
        'now'       => 'BasicEnglish',
        'find'      => 'BasicEnglish',
        'long'      => 'BasicEnglish',
        'part'      => 'BasicEnglish',
        'ok'        => 'BasicEnglish',
    );
    
    my %country_code = (
        "PE" => "CountryCode",
        "JO" => "CountryCode",
        "TG" => "CountryCode",
        "GM" => "CountryCode",
        "DZ" => "CountryCode",
        "GB" => "CountryCode",
        "PG" => "CountryCode",
        "IE" => "CountryCode",
        "BA" => "CountryCode",
        "MZ" => "CountryCode",
        "QA" => "CountryCode",
        "SB" => "CountryCode",
        "CA" => "CountryCode",
        "KZ" => "CountryCode",
        "SH" => "CountryCode",
        "OM" => "CountryCode",
        "TZ" => "CountryCode",
        "SN" => "CountryCode",
        "IL" => "CountryCode",
        "PT" => "CountryCode",
        "NU" => "CountryCode",
        "MN" => "CountryCode",
        "HU" => "CountryCode",
        "VI" => "CountryCode",
        "RW" => "CountryCode",
        "LV" => "CountryCode",
        "GN" => "CountryCode",
        "MA" => "CountryCode",
        "KM" => "CountryCode",
        "EC" => "CountryCode",
        "TD" => "CountryCode",
        "NF" => "CountryCode",
        "WS" => "CountryCode",
        "EE" => "CountryCode",
        "NI" => "CountryCode",
        "ZA" => "CountryCode",
        "WF" => "CountryCode",
        "TT" => "CountryCode",
        "CO" => "CountryCode",
        "PA" => "CountryCode",
        "US" => "CountryCode",
        "SO" => "CountryCode",
        "MQ" => "CountryCode",
        "JP" => "CountryCode",
        "VC" => "CountryCode",
        "HR" => "CountryCode",
        "CL" => "CountryCode",
        "VE" => "CountryCode",
        "TW" => "CountryCode",
        "YT" => "CountryCode",
        "LS" => "CountryCode",
        "ET" => "CountryCode",
        "MH" => "CountryCode",
        "GQ" => "CountryCode",
        "FR" => "CountryCode",
        "CR" => "CountryCode",
        "AR" => "CountryCode",
        #"ME" => "CountryCode",
        "TK" => "CountryCode",
        "BL" => "CountryCode",
        "BZ" => "CountryCode",
        "SA" => "CountryCode",
        "PH" => "CountryCode",
        "PM" => "CountryCode",
        "IS" => "CountryCode",
        "KG" => "CountryCode",
        "GF" => "CountryCode",
        "LY" => "CountryCode",
        "GR" => "CountryCode",
        "DO" => "CountryCode",
        "PL" => "CountryCode",
        "AG" => "CountryCode",
        "GW" => "CountryCode",
        "FI" => "CountryCode",
        "NE" => "CountryCode",
        "FK" => "CountryCode",
        "AE" => "CountryCode",
        "SE" => "CountryCode",
        "MW" => "CountryCode",
        "CF" => "CountryCode",
        "GH" => "CountryCode",
        "MX" => "CountryCode",
        "MY" => "CountryCode",
        "VA" => "CountryCode",
        "CY" => "CountryCode",
        "UA" => "CountryCode",
        "SZ" => "CountryCode",
        "SK" => "CountryCode",
        "DK" => "CountryCode",
        "PR" => "CountryCode",
        "BN" => "CountryCode",
        "SC" => "CountryCode",
        "ST" => "CountryCode",
        "AT" => "CountryCode",
        "VG" => "CountryCode",
        "MD" => "CountryCode",
        "AL" => "CountryCode",
        "HT" => "CountryCode",
        "KY" => "CountryCode",
        "AD" => "CountryCode",
        "CK" => "CountryCode",
        "HN" => "CountryCode",
        "BY" => "CountryCode",
        "RS" => "CountryCode",
        "TM" => "CountryCode",
        "ER" => "CountryCode",
        "AG" => "CountryCode",
        "IN" => "CountryCode",
        "TH" => "CountryCode",
        "TR" => "CountryCode",
        "HK" => "CountryCode",
        "AU" => "CountryCode",
        "BG" => "CountryCode",
        "GP" => "CountryCode",
        "BF" => "CountryCode",
        "BI" => "CountryCode",
        "KR" => "CountryCode",
        "ES" => "CountryCode",
        "IT" => "CountryCode",
        "SI" => "CountryCode",
        "AM" => "CountryCode",
        "JM" => "CountryCode",
        "ZR" => "CountryCode",
        "NO" => "CountryCode",
        "BA" => "CountryCode",
        "KE" => "CountryCode",
        "DE" => "CountryCode",
        "MM" => "CountryCode",
        "MG" => "CountryCode",
        "GL" => "CountryCode",
        "GT" => "CountryCode",
        "BE" => "CountryCode",
        "HK" => "CountryCode",
        "CI" => "CountryCode",
        "PF" => "CountryCode",
        "CM" => "CountryCode",
        "LB" => "CountryCode",
        "NZ" => "CountryCode",
        "CV" => "CountryCode",
        "PW" => "CountryCode",
        "KN" => "CountryCode",
        "US" => "CountryCode",
        "PK" => "CountryCode",
        "BR" => "CountryCode",
        "NA" => "CountryCode",
        "SV" => "CountryCode",
        "MP" => "CountryCode",
        "FM" => "CountryCode",
        "GE" => "CountryCode",
        "SM" => "CountryCode",
        "BJ" => "CountryCode",
        "RU" => "CountryCode",
        "ML" => "CountryCode",
        "CC" => "CountryCode",
        "KI" => "CountryCode",
        "LK" => "CountryCode",
        "MK" => "CountryCode",
        "UZ" => "CountryCode",
        "KP" => "CountryCode",
        "GY" => "CountryCode",
        "BO" => "CountryCode",
        "GA" => "CountryCode",
        "MF" => "CountryCode",
        "IQ" => "CountryCode",
        "CN" => "CountryCode",
        "CU" => "CountryCode",
        "AN" => "CountryCode",
        "BS" => "CountryCode",
        "GB" => "CountryCode",
        "LT" => "CountryCode",
        "US" => "CountryCode",
        "NL" => "CountryCode",
        "NG" => "CountryCode",
        "VU" => "CountryCode",
        "RE" => "CountryCode",
        "BT" => "CountryCode",
        "IR" => "CountryCode",
        "LR" => "CountryCode",
        "UM" => "CountryCode",
        "CG" => "CountryCode",
        "TC" => "CountryCode",
        "CH" => "CountryCode",
        "ID" => "CountryCode",
        "NC" => "CountryCode",
        "SD" => "CountryCode",
        "EG" => "CountryCode",
        "TJ" => "CountryCode",
        "RO" => "CountryCode",
        "CS" => "CountryCode",
        "BW" => "CountryCode",
        "SY" => "CountryCode",
        "AO" => "CountryCode",
        "YE" => "CountryCode",
        "TN" => "CountryCode",
        "ZW" => "CountryCode",
        "ZM" => "CountryCode",
        "AF" => "CountryCode",
        "VN" => "CountryCode",
        "MV" => "CountryCode",
        "LC" => "CountryCode",
        "AS" => "CountryCode",
        "MR" => "CountryCode",
        "LA" => "CountryCode",
        "UY" => "CountryCode",
        #"TO" => "CountryCode",
        "BD" => "CountryCode",
        "MC" => "CountryCode",
        "NP" => "CountryCode",
        "BB" => "CountryCode",
        "PY" => "CountryCode",
        "KH" => "CountryCode",
        "UG" => "CountryCode",
        "AZ" => "CountryCode",
        "LI" => "CountryCode",
        "SR" => "CountryCode",
        "TV" => "CountryCode",
        "RK" => "CountryCode",
        "FJ" => "CountryCode",
    );   
    
    my %city_in_more_country = (
        'Sinop'       => 1,
        'Ardmore'     => 1,
        'Geraldton'   => 1,
        'Marathon'    => 1,
        'Anguilla'    => 1,
        'Corozal'     => 1,
        'Bursa'       => 1,
        'Valparaiso'  => 1,
        'Sydney'      => 1,
        'Eureka'      => 1,
        'Merida'      => 1,
        'Kingston'    => 1,
        'Butterworth' => 1,
        'Concordia'   => 1,
        'Newcastle'   => 1,
        'London'      => 1,
        'Alexandria'  => 1,
        'Greenwood'   => 1,
        'Messina'     => 1,
        'Plymouth'    => 1,
        'Aberdeen'    => 1,
        'Sparta'      => 1,
        'Bali'        => 1,
        'Creston'     => 1,
        'Moron'       => 1,
        'Manzanillo'  => 1,
        'Salina'      => 1,
        'Parana'      => 1,
        'Queenstown'  => 1,
        'Banmethuot'  => 1,
        'Palacios'    => 1,
        'Oxford'      => 1,
        'Wellington'  => 1,
        'Jasper'      => 1,
        'Cochrane'    => 1,
        'Ipswich'     => 1,
        'Oran'        => 1,
        'Kochi'       => 1,
        'Stuttgart'   => 1,
        'Valencia'    => 1,
        'Bol'         => 1,
        'Pemba'       => 1,
        'Moanda'      => 1,
        'Monterrey'   => 1,
        'Florence'    => 1,
        'Naha'        => 1,
        'Manchester'  => 1,
        'Rosario'     => 1,
        'Tripoli'     => 1,
        'Colon'       => 1,
        'Independence'=> 1,
        'Salinas'     => 1,
        'Kimberley'   => 1,
        'Portsmouth'  => 1,
        'Centralia'   => 1,
        'Belfast'     => 1,
        'Trujillo'    => 1,
        'Ladysmith'   => 1,
        'Daru'        => 1,
        'Concepcion'  => 1,
        'Georgetown'  => 1,
        'Wau'         => 1,
        'Naples'      => 1,
        'Camden'      => 1,
        'Freeport'    => 1,
        'Brest'       => 1,
        'Durango'     => 1,
        'Hyderabad'   => 1,
        'Melbourne'   => 1,
        'Salem'       => 1,
        'Roma'        => 1,
        'Norwich'     => 1,
        'Dili'        => 1,
        'Trinidad'    => 1,
        'Vichy'       => 1,
        'Kamina'      => 1,
        'Ayacucho'    => 1,
        'Moyale'      => 1,
        'Abingdon'    => 1,
        'Cambridge'   => 1,
        'Chatham'     => 1,
        'Birmingham'  => 1,
        'Cordoba'     => 1,
        'Kilwa'       => 1,
        'Alma'        => 1,
        'Arica'       => 1,
        'Oban'        => 1,
        'Kiunga'      => 1,
        'Waterloo'    => 1,
        'Santiago'    => 1,
        'Trenton'     => 1,
        'Barra'       => 1,
        'Namu'        => 1,
        'Bathurst'    => 1,
        'Midland'     => 1,
        'Wainwright'  => 1,
        'Mitchell'    => 1,
        'Latrobe'     => 1,
        'Arona'       => 1,
        'Mendi'       => 1,
        'Nogales'     => 1,
        'Vitoria'     => 1,
        'Bradford'    => 1,
        'Stephenville'=> 1,
        'Torres'      => 1,
        'Limon'       => 1
    );
    
    my %first_word_in_cityname = (
        'yes' => 1,
        'ila' => 1,
        'aek' => 1,
        'yun' => 1,
        'icy' => 1,
        'two' => 1,
        'key' => 1,
        'aua' => 1,
        'kar' => 1,
        'hat' => 1,
        'tel' => 1,
        'hay' => 1,
        'avu' => 1,
        'paf' => 1,
        'iwo' => 1,
        'bom' => 1,
        'boa' => 1,
        'eau' => 1,
        'cap' => 1,
        'paz' => 1,
        'dom' => 1,
        'ida' => 1,
        'qui' => 1,
        'old' => 1,
        'sui' => 1,
        'sun' => 1,
        'one' => 1,
        'ras' => 1,
        'phu' => 1,
        'mae' => 1,
        'oum' => 1,
        'seo' => 1,
        'pan' => 1,
        'lac' => 1,
        'hoy' => 1,
        'fak' => 1,
        'tai' => 1,
        'she' => 1,
        'chi' => 1,
        'cat' => 1,
        'gag' => 1,
        'con' => 1,
        'pos' => 1,
        'ann' => 1,
        'tin' => 1,
        'abu' => 1,
        'yan' => 1,
        'rum' => 1,
        'roy' => 1,
        'ine' => 1,
        'bay' => 1,
        'del' => 1,
        'wha' => 1,
        'ord' => 1,
        'val' => 1,
        'rea' => 1,
        'can' => 1,
        'yam' => 1,
        'gal' => 1,
        'den' => 1,
        'now' => 1,
        'dos' => 1,
        'oki' => 1,
        'oak' => 1,
        'hot' => 1,
        'the' => 1,
        'les' => 1,
        'tuy' => 1,
        'ein' => 1,
        'wad' => 1,
        'phi' => 1,
        'red' => 1,
        'fin' => 1,
        'aur' => 1,
        'doc' => 1,
        'eva' => 1,
        'xin' => 1,
        'zhi' => 1,
        'roi' => 1,
        'mar' => 1,
        'may' => 1,
        'sam' => 1,
        'gan' => 1,
        'dar' => 1,
        'rae' => 1,
        'tan' => 1,
        'des' => 1,
        'san' => 1,
        'nha' => 1,
        'las' => 1,
        'tom' => 1,
        'cut' => 1,
        'lae' => 1,
        'sue' => 1,
        'umm' => 1,
        'ban' => 1,
        'car' => 1,
        'elk' => 1,
        'oil' => 1,
        'big' => 1,
        'soc' => 1,
        'los' => 1,
        'fox' => 1,
        'koh' => 1,
        'van' => 1,
        'ile' => 1

    );
    
    my %three_letter_verb = (
        'ply' => 1,
        'fog' => 1,
        'ape' => 1,
        'fly' => 1,
        'put' => 1,
        'pit' => 1,
        'key' => 1,
        'buy' => 1,
        'gum' => 1,
        'pun' => 1,
        'hat' => 1,
        'sop' => 1,
        'pur' => 1,
        'dug' => 1,
        'sod' => 1,
        'won' => 1,
        'fit' => 1,
        'lam' => 1,
        'pen' => 1,
        'sit' => 1,
        'zig' => 1,
        'sun' => 1,
        'cop' => 1,
        'bog' => 1,
        'dig' => 1,
        'ink' => 1,
        'ski' => 1,
        'fub' => 1,
        'beg' => 1,
        'vat' => 1,
        'pat' => 1,
        'ate' => 1,
        'gas' => 1,
        'rap' => 1,
        'pan' => 1,
        'die' => 1,
        'pug' => 1,
        'lug' => 1,
        'gag' => 1,
        'con' => 1,
        'lie' => 1,
        'pap' => 1,
        'act' => 1,
        'bay' => 1,
        'tug' => 1,
        'kip' => 1,
        'nag' => 1,
        'can' => 1,
        'aim' => 1,
        'jib' => 1,
        'sow' => 1,
        'bib' => 1,
        'man' => 1,
        'dog' => 1,
        'toe' => 1,
        'bid' => 1,
        'wet' => 1,
        'led' => 1,
        'hip' => 1,
        'gab' => 1,
        'pay' => 1,
        'bit' => 1,
        'mop' => 1,
        'bud' => 1,
        'err' => 1,
        'wad' => 1,
        'sot' => 1,
        'sip' => 1,
        'pad' => 1,
        'tap' => 1,
        'paw' => 1,
        'jag' => 1,
        'got' => 1,
        'gob' => 1,
        'pot' => 1,
        'sup' => 1,
        'tag' => 1,
        'jab' => 1,
        'arc' => 1,
        'nod' => 1,
        'sag' => 1,
        'hid' => 1,
        'may' => 1,
        'ask' => 1,
        'sob' => 1,
        'sin' => 1,
        'zip' => 1,
        'rim' => 1,
        'dun' => 1,
        'tan' => 1,
        'mug' => 1,
        'jam' => 1,
        'hex' => 1,
        'tar' => 1,
        'gyp' => 1,
        'fan' => 1,
        'pie' => 1,
        'add' => 1,
        'bus' => 1,
        'hum' => 1,
        'par' => 1,
        'nix' => 1,
        'hit' => 1,
        'ham' => 1,
        'war' => 1,
        'bug' => 1,
        'pew' => 1,
        'run' => 1,
        'cut' => 1,
        'cow' => 1,
        'get' => 1,
        'dam' => 1,
        'pig' => 1,
        'dab' => 1,
        'dip' => 1,
        'ace' => 1,
        'bat' => 1,
        'rig' => 1,
        'vex' => 1,
        'sue' => 1,
        'don' => 1,
        'cry' => 1,
        'orb' => 1,
        'lag' => 1,
        'tax' => 1,
        'lin' => 1,
        'oil' => 1,
        'fox' => 1,
        'dry' => 1,
        'lip' => 1,
        'woo' => 1,
        'pee' => 1,
        'owe' => 1,
        'ebb' => 1,
        'has' => 1,
        'tip' => 1,
        'map' => 1,
        'row' => 1,
        'ran' => 1,
        'dim' => 1,
        'sum' => 1,
        'mew' => 1,
        'ken' => 1,
        'out' => 1,
        'nib' => 1,
        'cap' => 1,
        'arm' => 1,
        'zag' => 1,
        'rat' => 1,
        'mob' => 1,
        'top' => 1,
        'caw' => 1,
        'ram' => 1,
        'axe' => 1,
        'eat' => 1,
        'leg' => 1,
        'wow' => 1,
        'bet' => 1,
        'wed' => 1,
        'web' => 1,
        'hog' => 1,
        'lap' => 1,
        'lit' => 1,
        'sap' => 1,
        'set' => 1,
        'ail' => 1,
        'kid' => 1,
        'jog' => 1,
        'tie' => 1,
        'bag' => 1,
        'irk' => 1,
        'peg' => 1,
        'try' => 1,
        'vie' => 1,
        'pop' => 1,
        'gut' => 1,
        'pin' => 1,
        'bed' => 1,
        'met' => 1,
        'tod' => 1,
        'tee' => 1,
        'max' => 1,
        'wax' => 1,
        'net' => 1,
        'fet' => 1,
        'jut' => 1,
        'yap' => 1,
        'mud' => 1,
        'shy' => 1,
        'gap' => 1,
        'let' => 1,
        'win' => 1,
        'lay' => 1,
        'moo' => 1,
        'pry' => 1,
        'mar' => 1,
        'awe' => 1,
        'mow' => 1,
        'lob' => 1,
        'dob' => 1,
        'bow' => 1,
        'wag' => 1,
        'eke' => 1,
        'rib' => 1,
        'rag' => 1,
        'jot' => 1,
        'are' => 1,
        'rob' => 1,
        'age' => 1,
        'amp' => 1,
        'git' => 1,
        'use' => 1,
        'tab' => 1,
        'fry' => 1,
        'say' => 1,
        'pal' => 1,
        'sew' => 1,
        'had' => 1,
        'yen' => 1,
        'ban' => 1,
        'bop' => 1,
        'hoe' => 1,
        'rot' => 1,
        'mix' => 1,
        'pet' => 1,
        'fob' => 1,
        'was' => 1,
        'sub' => 1,
        'dub' => 1,
        'hug' => 1,
        'jar' => 1,
        'sat' => 1,
        'bob' => 1,
        'nap' => 1,
        'air' => 1,
        'bum' => 1,
        'for' => 1,
        'chp' => 1,
        'way' => 1,
        'off' => 1
    );
    
    my %calendar_abbreviation = (
        'jan'   => 1,
        'feb'   => 1,
        'mar'   => 1,
        'apr'   => 1,
        'may'   => 1,
        'jun'   => 1,
        'jul'   => 1,
        'aug'   => 1,
        'sep'   => 1,
        'oct'   => 1,
        'nov'   => 1,
        'dec'   => 1,
        'mon'   => 1,
        'tue'   => 1,
        'wed'   => 1,
        'thu'   => 1,
        'fri'   => 1,
        'sat'   => 1,
        'sun'   => 1,
    );

=head2 is_this_word_three_letter_verb

is_this_word_three_letter_verb will check its a three letter word.

=cut

    sub is_this_word_three_letter_verb {
        my ($data)    = @_;
        
        return (defined $three_letter_verb{ lc($data) })? 1 : 0;
    }

=head2 is_this_word_calendar_abbreviation

is_this_word_calendar_abbreviation 3 letter word for Mon-Sun or Jan-Dec.

=cut

    sub is_this_word_calendar_abbreviation {
        my ($data)    = @_;
        
        return (defined $calendar_abbreviation{ lc($data) })? 1 : 0;
    }

=head2 is_this_word_start_of_cityname

is_this_word_start_of_cityname will check beggining cityname for two/three letter word i.e Las Vegas or Los angeles.

=cut

    sub is_this_word_start_of_cityname {
        my ($data)    = @_;
        
        return (defined $first_word_in_cityname{ lc($data) })? 1 : 0;
    }

=head2 is_this_city_in_more_than_one_country

is_this_city_in_more_than_one_country check is this city is in more than one country.

=cut

    sub is_this_city_in_more_than_one_country {
        my ($data)    = @_;
        
        return (defined $city_in_more_country{ ucfirst($data) })? 1 : 0;
    }

=head2 is_search_keywords

checks for classification of word.

=cut

    sub is_search_keywords {
        my $data    = shift;
        
        given($data) {
            when(defined $key_words{ $_}) {
                return $key_words{ $_};
            };
            when(defined $country_code{ uc($_) }) {
                return $country_code{ uc($_) };     
            };
            default {
                return "Regular";
            };
        }
    }

=head2 convert_search_keywords

convert_search_keywords cheks for possible conversion of word.

=cut

    sub convert_search_keywords {
        my $token   = shift;

        croak "Not a object of Travel::Search::Token" if(ref($token) ne 'Travel::Search::Token');
        my $str = $token->data; 
        
        given($str) {
            when(defined $numbers{$_})  {
                $token->replace_data($numbers{$str});
                $token->has_number(1);
                return;
            };
            when(defined $months{$_}) {
                $token->class($months{$str});
                return;
            };
            when(defined $week_days{$_}) {
                $token->class($week_days{$str});
                return;
            };
        }
        
        foreach my $month (keys %months){
            next if length($str) < 3;
            if($month =~ /^$str/x) {
                $token->replace_data($month);
                $token->class($months{ $month });
                return;
            }
        }
        
        foreach my $day (keys %week_days){
            next if length($str) < 3;
            if($day =~ /^$str/x) {
                $token->replace_data($day);
                $token->class($week_days{ $day });
                return;
            }
        }
        
        return;
    }

=head2 get_class_of_word

get_class_of_word checks for the class of word.

=cut

    sub get_class_of_word {
        my ($data)    = @_;
        
        my $class  = 'Regular';
        
        if($key_words{ $data }) {
            $class  = $key_words{ $data };
        }
        elsif($week_days{ $data }){
            $class  = $week_days{ $data };
        }
        elsif($months{ $data }){
            $class  = $months{ $data };
        }
        elsif(defined $numbers{ $data }) {
            $class  = 'Numbers';
        }
        
        return $class;
    }

    my $invalid_province_code   = {
        'in'    => 1,
        'me'    => 1,
        'to'    => 1
    };
    
=head2 invalid_province_to_use

invalid_province_to_use returns true if this code value may be mean differently

=cut

    sub invalid_province_to_use {
        my ($data)    = @_;
        
        return $invalid_province_code->{ $data };
    }
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;