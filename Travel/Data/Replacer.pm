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

package Travel::Data::Replacer;

=head1 NAME

Travel::Data::Replacer contains various configuration required for data replacement.

=head1 SYNOPSIS

    use Travel::Data::Replacer qw(
        replace_country_name
        replace_search_abbreviations
        replace_month_strings
        spelling_check
   );

=head1 DESCRIPTION

Travel::Data::Replacer performs various data replacement activities.

=cut

use base qw( Exporter );

use strict;
use warnings;
use Data::Dumper;
use Date::Manip::Date;

use lib qw(../../);
use General::SpellCheck::Simple;
use Travel::Data::Config qw(number_to_month);
use Travel::Data::Dictionary qw(get_class_of_word);

our @EXPORT_OK = qw(
    replace_country_name
    replace_search_abbreviations
    replace_month_strings
    spelling_check
);

{
    my %search_abbreviations = (
        'chp flts'          => 'cheap flights',
        'chp flt'           => 'cheap flight',
        'wensday'           => 'wednesday'
    );
    
    my %country_name = (        
        #"afghanistan"       => "AF",
        #"albania"           => "AL",
        #"algeria"           => "DZ",
        "american samoa"    => "AS",
        #"andorra"           => "AD",
        #"angola"            => "AO",
        #"antigua"           => "AG",
        #"barbuda"           => "AG",
        #"argentina"         => "AR",
        #"armenia"           => "AM",
        #"australia"         => "AU",
        #"austria"           => "AT",
        #"azerbaijan"        => "AZ",
        #"bahamas"           => "BS",
        #"bangladesh"        => "BD",
        #"barbados"          => "BB",
        #"belarus"           => "BY",
        #"belgium"           => "BE",
        #"belize"            => "BZ",
        #"benin"             => "BJ",
        #"bhutan"            => "BT",
        #"bolivia"           => "BO",
        #"bosnia"            => "BA",
        #"herzegovina"       => "BA",
        #"botswana"          => "BW",
        #"brazil"            => "BR",
        "brunei darussalam" => "BN",
        #"bulgaria"          => "BG",
        "burkina faso"      => "BF",
        #"burundi"           => "BI",
        #"cambodia"          => "KH",
        #"cameroon"          => "CM",
        #"canada"            => "CA",
        "cape verde"        => "CV",
        "cayman islands"    => "KY",
        #"chad"              => "TD",
        #"chile"             => "CL",
        #"china"             => "CN",
        #"colombia"          => "CO",
        #"comoros"           => "KM",
        #"congo"             => "CG",
        "cook islands"      => "CK",
        "costa rica"        => "CR",
        #"croatia"           => "HR",
        #"cuba"              => "CU",
        #"cyprus"            => "CY",
        "czech republic"    => "CS",
        #"denmark"           => "DK",
        "dominican republic"=> "DO",
        #"ecuador"           => "EC",
        #"egypt"             => "EG",
        "el salvador"       => "SV",
        "equatorial guinea" => "GQ",
        #"eritrea"           => "ER",
        #"estonia"           => "EE",
        #"ethiopia"          => "ET",
        "falkland islands"  => "FK",
        #"fiji"              => "FJ",
        #"finland"           => "FI",
        #"france"            => "FR",
        "french guiana"     => "GF",
        "french polynesia"  => "PF",
        #"gabon"             => "GA",
        #"gambia"            => "GM",
        #"georgia"           => "GE",
        #"germany"           => "DE",
        #"ghana"             => "GH",
        #"greece"            => "GR",
        #"greenland"         => "GL",
        #"guadeloupe"        => "GP",
        #"guatemala"         => "GT",
        #"guinea"            => "GN",
        "guinea-bissau"     => "GW",
        #"guyana"            => "GY",
        #"haiti"             => "HT",
        #"honduras"          => "HN",
        "hong kong"         => "HK",
        #"hungary"           => "HU",
        #"iceland"           => "IS",
        #"india"             => "IN",
        #"indonesia"         => "ID",
        #"iran"              => "IR",
        #"iraq"              => "IQ",
        #"ireland"           => "IE",
        #"israel"            => "IL",
        #"italy"             => "IT",
        #"jamaica"           => "JM",
        #"japan"             => "JP",
        #"jordan"            => "JO",
        #"kazakhstan"        => "KZ",
        #"kenya"             => "KE",
        #"kiribati"          => "KI",
        "north korea"       => "KP",
        "south korea"       => "KR",
        #"kyrgyzstan"        => "KG",
        #"laos"              => "LA",
        #"latvia"            => "LV",
        #"lebanon"           => "LB",
        #"lesotho"           => "LS",
        #"liberia"           => "LR",
        #"libya"             => "LY",
        #"liechtenstein"     => "LI",
        #"lithuania"         => "LT",
        #"madagascar"        => "MG",
        #"malawi"            => "MW",
        #"malaysia"          => "MY",
        #"maldives"          => "MV",
        #"mali"              => "ML",
        "marshall islands"  => "MH",
        #"martinique"        => "MQ",
        #"mauritania"        => "MR",
        #"mayotte"           => "YT",
        #"mexico"            => "MX",
        #"micronesia"        => "FM",
        #"moldova"           => "MD",
        #"monaco"            => "MC",
        #"mongolia"          => "MN",
        #"morocco"           => "MA",
        #"mozambique"        => "MZ",
        #"myanmar"           => "MM",
        #"namibia"           => "NA",
        #"nepal"             => "NP",
        #"netherlands"       => "NL",
        "new caledonia"     => "NC",
        "new zealand"       => "NZ",
        #"nicaragua"         => "NI",
        #"niger"             => "NE",
        #"nigeria"           => "NG",
        #"niue"              => "NU",
        "norfolk island"    => "NF",
        #"norway"            => "NO",
        #"oman"              => "OM",
        #"pakistan"          => "PK",
        #"palau"             => "PW",
        #"panama"            => "PA",
        "papua new guinea"  => "PG",
        #"paraguay"          => "PY",
        #"peru"              => "PE",
        #"philippines"       => "PH",
        #"poland"            => "PL",
        #"portugal"          => "PT",
        "puerto rico"       => "PR",
        #"qatar"             => "QA",
        #"reunion"           => "RE",
        "republic of serbia"=> "RS",
        "republic of kosovo"=> "RK",
        #"romania"           => "RO",
        "russian federation"=> "RU",
        #"rwanda"            => "RW",
        "saint barthelemy"  => "BL",
        "saint lucia"       => "LC",
        "saint martin"      => "MF",
        #"samoa"             => "WS",
        "san marino"        => "SM",
        "saotome & principe"=> "ST",
        "saudi arabia"      => "SA",
        #"senegal"           => "SN",
        "seychelles"        => "SC",
        "slovak republic"   => "SK",
        #"slovenia"          => "SI",
        "solomon islands"   => "SB",
        #"somalia"           => "SO",
        "south africa"      => "ZA",
        #"spain"             => "ES",
        "sri lanka"         => "LK",
        "st.helena"         => "SH",
        #"sudan"             => "SD",
        #"suriname"          => "SR",
        #"swaziland"         => "SZ",
        #"sweden"            => "SE",
        "switzerland"       => "CH",
        #"syria"             => "SY",
        #"taiwan"            => "TW",
        #"tajikistan"        => "TJ",
        #"tanzania"          => "TZ",
        #"thailand"          => "TH",
        #"togo"              => "TG",
        #"tokelau"           => "TK",
        #"tonga"             => "TO",
        "trinidad & tobago" => "TT",
        #"tunisia"           => "TN",
        #"turkey"            => "TR",
        #"turkmenistan"      => "TM",
        #"tuvalu"            => "TV",
        #"uganda"            => "UG",
        #"ukraine"           => "UA",
        "unitedkingdom"     => "GB",
        "unitedstates"      => "USA",
        "united kingdom"    => "GB",
        "united states"     => "USA",
        #"usa"               => "US",
        #"uruguay"           => "UY",
        "us minor islands"  => "UM",
        #"uzbekistan"        => "UZ",
        #"vanuatu"           => "VU",
        #"venezuela"         => "VE",
        "viet nam"          => "VN",
        #"yemen"             => "YE",
        #"zaire"             => "ZR",
        #"zambia"            => "ZM",
        #"zimbabwe"          => "ZW",
        "central african republic"  => "CF",
        "cocos(keeling) islands"    => "CC",
        "cote divoire(ivory coast)" => "CI",
        "holy see (vatican city)"   => "VA",
        "netherlands antilles"      => "AN",
        "northern mariana islands"  => "MP",
        "people's republic of china"=> "HK",
        #"republic of montenegro"    => "ME",
        "republic of macedonia"     => "MK",
        "saintvincent & grenadines" => "VC",
        "saint kitts & nevis"       => "KN",
        "st.pierre & miquelon"      => "PM",
        "turks & caicos islands"    => "TC",
        "united arab emirates"      => "AE",
        "virgin islands(british)"   => "VG",
        "virgin islands(u.s.)"      => "VI",
        "wallis & futuna islands"   => "WF" 
    );

=head1 METHODS

=head2 replace_search_abbreviations

replace_search_abbreviations replaces various short words to full meaningful word

=cut

    sub replace_search_abbreviations {
        my ($string) = @_;
        
        $string = lc($string);
        foreach my $line (keys %search_abbreviations) {
            if( $string =~ /$line/) {
                $string =~ s/$line/$search_abbreviations{ $line }/g;
            }
        }
        
        return lc($string);
    }

=head2 replace_country_name

replace_country_name with country code

=cut

    sub replace_country_name {
        my ($string) = @_;
        
        $string = lc($string);
        foreach my $name (keys %country_name) {
            if( $string =~ /$name/) {
                $string =~ s/$name/$country_name{ $name }/g;
            }
        }
        
        return lc($string);
    }

=head2 replace_month_strings

replace_month_strings strings with respected value.

=cut

    sub replace_month_strings {
        my ($string) = @_;
        
        my $date = Date::Manip::Date->new();
        if( $string =~ /this\s+month/x) {
            $date->parse("today");
            my @dates   = $date->value;
            
            my $mon = number_to_month($dates[1]);
            $string =~ s/this\s+month/$mon/xg;
        }
        
        if( $string =~ /next\s+month/x) {
            $date->parse("next month");
            my @dates   = $date->value;
            
            my $mon = number_to_month($dates[1]);
            $string =~ s/next\s+month/$mon/xg;
        }
        
        return $string;
    }

=head2 spelling_check

spelling_check checks the spelling of each word in the string and replaces it with correct word.

=cut

    sub spelling_check {
        my ($string) = @_;
        my @data    = split(/\s+/x, $string);
    
        my $dictionary  = General::SpellCheck::Simple->new();
        for(my $i = 0; $i <= scalar(@data); $i++) {
            if(!$dictionary->is_spell_correct($data[$i])) {
                next if length($data[$i]) <= 3;
                my @suggestions = $dictionary->suggestions($data[$i]);
                if(scalar(@suggestions) >= 1 && get_class_of_word($suggestions[0]->{ $data[$i] }->[0]) ne 'Regular'){
                    #print "Replace ", $data[$i], " with ", $suggestions[0]->{ $data[$i] }->[0], "\n";
                    $data[$i]   = $suggestions[0]->{ $data[$i] }->[0];
                }
            }
        }
        
        return lc(join(" ", @data));
    }
}

=head1 LICENSE

This library is private software. You can not redistribute it and/or modify. Its a property of PerlCraft.net

=cut

1;