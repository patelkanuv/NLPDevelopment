use strict;
use warnings;

use Data::Dumper;
use lib qw(../../);
use Travel::Database::DBConfig qw( get_handle );
use Travel::Database::Schema::Result::City;

my $dbm     = Travel::Database::DBConfig->new;
my $schema  = $dbm->get_handle();

my @cities = qw(
                Princeton
                Alexandria
                Osaka
                Moultrie
                Fairbanks
                Ladysmith
                Wilmington
                Nha Trang
                Portland
                Naples
                Leesburg
                Oxnard / Ventura
                Houston
                Plattsburgh
                Paris
                Freetown
                Santa Rosa
                San Jose
                Paramaribo
                Bimini
                Geraldton
                Ketchikan
                Mildenhall
                Crooked Creek
                Fairmont
                Laurel
                Glasgow
                Yaounde
                Mt Clemens
                Lincoln
                Tripoli
                Sargodha
                Helsingborg
                San Rafael
                St Lucia
                Wau
                Newton
                Oshkosh
                Springfield
                Florence
                Adana
                Otjiwarongo
                Umnak Island
                Oran
                Shelby
                Greenville
                Aitape
                Jasper
                Centerville
                Kiev
                Georgetown
                Vail/Eagle
                Rosh Pina
                Plymouth
                Treviso
                Bowling Green
                Newport
                Indianapolis
                Shetland Islands
                Bradford
                London
                Detroit
                Ardmore
                Port Elizabeth
                Palmer
                Ampara
                Rio Grande
                Bedford
                Sinop
                Centralia
                Christmas Island
                San Ignacio
                Meridian
                Deer Lake
                Emporia
                Alma
                Waterloo
                Petersburg
                Sidney
                Camden
                Pretoria
                Kodiak
                Muskogee
                Kiunga
                Kuala Lumpur
                Isles Of Scilly
                Palacios
                Fayetteville
                Marshall
                San Salvador
                Merida
                Kota Kinabalu
                Corozal
                Kuantan
                Wausau
                Sault Ste Marie
                Lexington
                Kipnuk
                Oban
                Matanzas
                Shanghai
                Jamestown
                Newtok
                Humboldt
                La Grande
                Daru
                Stockholm
                Mt Pleasant
                Martinsburg
                Barrow
                Sparta
                Stuttgart
                Balikesir
                Buenos Aires
                Macau
                Charleston
                Hyderabad
                Now Shahr
                Barra
                Belo Horizonte /Belo Horizon
                Lewiston
                Milan
                St Croix Island
                Wilkes-Barre
                Porto Alegre
                Naha
                Nottingham
                Mount Pleasant
                Noumea
                Rochester
                Vichy
                Fairfield
                Sinoe
                Boulder
                Yuma
                Valencia
                Watertown
                Santa Ynez
                Augusta
                Moyale
                Breckenridge
                Humacao
                Rome
                Craig
                Monticello
                Santa Fe
                Peawanuck
                Minsk
                Makkovik
                Independence
                Batesville
                Anniston
                Pilot Point
                Moanda
                San Carlos
                Salem
                Helena
                Eureka
                Ely
                Durango
                Leeds
                Clinton
                Danville
                Green River
                Sanford
                Trinidad
                Trujillo
                Columbus
                Emmen
                Hawthorne
                Mesquite
                Oxford
                Anguilla
                Fort Smith
                Mount Cook
                Cordova
                Tehran
                Perry
                Belo Horizonte
                Concordia
                Cordoba
                Foley
                Freeport
                Bethel
                Moron
                Butler
                Tamky
                Eskisehir
                Salisbury
                Bathurst
                Prince Rupert
                Beaumont
                Dili
                San Julian
                Jackson
                Ayacucho
                Toulon
                Palm Island
                Monrovia
                Chignik
                Saint Tropez
                Puerto Rico
                Chesapeake
                Mitchell
                Rio De Janeiro
                Lancaster
                Campbell River
                Moroni
                Abingdon
                Danbury
                Panama City
                Doncaster
                Chicago
                Brookings
                Dominica
                Rangpur
                Concord
                Charlottetown
                Casablanca
                Cherokee
                Stuart Island
                Cumberland
                Santa Maria
                Sapporo
                Kochi
                Decatur
                Puerto La Cruz
                Malmo
                Versailles
                Messina
                Medellin
                Marion
                Toronto
                Terrace Bay
                Lupin
                Catalina Island
                Santiago
                San Felipe
                Arona
                Frederick
                Stephenville
                Torres
                Lake Charles
                Tonopah
                Salina
                Tete
                La Paz
                Penang
                Morristown
                Belfast
                Grand Rapids
                Vojens
                Pemba
                San Fernando
                Mendi
                Brussels
                Tofino
                Punta Gorda
                Marathon
                Utica
                Hillsboro
                Twentynine Palms
                Aberdeen
                Robinson River
                Lawrence
                Big Creek
                Weeze
                Huntington
                Nogales
                Dillon
                Saposoa
                Mulhouse/Basel
                Banmethuot
                Tallinn
                Rocky Mount
                Rosario
                Geilo
                Sonderborg
                Taichung
                Cambridge
                Santo Domingo
                Shetland Islands /Shetland Isd
                Heidelberg
                Sydney
                Wellington
                Waco
                State College
                San Luis Obispo
                Queenstown
                Santa Cruz
                San Juan
                Arica
                Franklin
                Jacksonville
                Port Angeles
                Webequie
                Guam
                Santa Rosalia
                Latrobe
                Resende
                Elkhart
                Nicosia
                Santa Ana
                Lawrenceville
                Bloomington
                Seoul
                Portsmouth
                Auburn
                Tokyo
                Namu
                Tullahoma
                San Cristobal
                Manchester
                Long Island
                Concepcion
                Fond Du Lac
                Hobbs
                Kalispell
                St Martin
                Bauru
                Medford
                Hot Springs
                Brunswick
                Apia
                Taylor
                Bol
                Salinas
                Nelspruit
                Ipswich
                Butterworth
                Springvale
                Bursa
                Rockford
                Moscow
                San Pedro
                Tortola
                St Petersburg
                Berlin
                Newcastle
                Pikangikum
                New York
                Milwaukee
                Hiroshima
                Greenwood
                Riyadh
                Wiesbaden
                Lanzhou
                Imperial
                Rennes
                Futuna Island
                Refugio
                Sullivan
                Kamina
                Boa Vista
                Valparaiso
                St. Marys
                George Town
                Xi An
                Kingston
                Monterrey
                El Dorado
                Parana
                Nacogdoches
                Carlsbad
                Niort
                Olney
                Norwich
                Monroe
                Toledo
                Port Harcourt
                Madison
                Colon
                Melbourne
                Kilwa
                Kauai Island
                Cochrane
                Washington
                Chatham
                Vitoria
                St Thomas Island
                Midland
                Mount Vernon
                Douglas
                Baku
                Quincy
                Greenfield
                Birmingham
                Egegik
                Omaha
                Izmir
                Columbia
                Hutchinson
                Port Townsend
                White River
                Creston
                Limon
                Kimberley
                Farmington
                Burlington
                Easton
                Grand Canyon
                Macon
                Grand Forks
                Jefferson
                Harrisburg
                Edmonton
                Wainwright
                Akron/Canton
                Seattle
                Roma
                Brest
                Riverside
                Manzanillo
                Tenerife
                Hayward
                Tianjin
                Phoenix
                Bali
                Sao Paulo
                Trenton
);
my %city1;

foreach my $city (@cities) {
    my @all_airports = $schema->resultset('City')->search(
        {   'LOWER(city_name)'  => lc($city) }
    );
    my %hash;
    
    foreach my $airport (@all_airports) {
        $hash{ $airport->country_code } = 1;
        if(scalar(keys %hash) > 1){
            $city1{ $airport->city_name } = 1;    
            print $airport->city_name, " - ", $airport->country_name, " - ",$airport->airport_code, "\n";
        }
    }
}

print Dumper \%city1;
