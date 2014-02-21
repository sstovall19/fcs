package Fap::Data::Countries;
use strict;

our $_state_list = {
    'AUS' => {
        'NT'  => 'Northern Territory',
        'SA'  => 'South Australia',
        'VIC' => 'Victoria',
        'ACT' => 'Australian Capital Territory',
        'QLD' => 'Queensland',
        'TAS' => 'Tasmania',
        'WA'  => 'Western Australia',
        'NSW' => 'New South Wales'
    },
    'USA' => {
        'SC' => 'South Carolina',
        'LA' => 'Louisiana',
        'GU' => 'Guam',
        'NC' => 'North Carolina',
        'MS' => 'Mississippi',
        'OK' => 'Oklahoma',
        'NY' => 'New York',
        'VA' => 'Virginia',
        'HI' => 'Hawaii',
        'PA' => 'Pennsylvania',
        'NE' => 'Nebraska',
        'SD' => 'South Dakota',
        'PR' => 'Puerto Rico',
        'DC' => 'District of Columbia',
        'OH' => 'Ohio',
        'WV' => 'West Virginia',
        'WI' => 'Wisconsin',
        'NM' => 'New Mexico',
        'MO' => 'Missouri',
        'MH' => 'Marshall Islands',
        'NH' => 'New Hampshire',
        'AZ' => 'Arizona',
        'MA' => 'Massachusetts',
        'MT' => 'Montana',
        'MN' => 'Minnesota',
        'MP' => 'Northern Mariana Islands',
        'TX' => 'Texas',
        'ME' => 'Maine',
        'NJ' => 'New Jersey',
        'WY' => 'Wyoming',
        'NV' => 'Nevada',
        'WA' => 'Washington',
        'OR' => 'Oregon',
        'PW' => 'Palau',
        'ID' => 'Idaho',
        'FM' => 'Fed. States of Micronesia',
        'RI' => 'Rhode Island',
        'AL' => 'Alabama',
        'UT' => 'Utah',
        'TN' => 'Tennessee',
        'KS' => 'Kansas',
        'ND' => 'North Dakota',
        'FL' => 'Florida',
        'AS' => 'American Samoa',
        'CT' => 'Connecticut',
        'MD' => 'Maryland',
        'CA' => 'California',
        'IA' => 'Iowa',
        'DE' => 'Delaware',
        'CO' => 'Colorado',
        'MI' => 'Michigan',
        'IN' => 'Indiana',
        'AR' => 'Arkansas',
        'VT' => 'Vermont',
        'VI' => 'Virgin Islands',
        'GA' => 'Georgia',
        'KY' => 'Kentucky',
        'AK' => 'Alaska',
        'IL' => 'Illinois'
    },
    'CAN' => {
        'NT' => 'Northwest Territories',
        'BC' => 'British Columbia',
        'NS' => 'Nova Scotia',
        'ON' => 'Ontario',
        'YT' => 'Yukon',
        'QC' => 'Quebec',
        'MB' => 'Manitoba',
        'NF' => 'Newfoundland',
        'PE' => 'Prince Edward Island',
        'NB' => 'New Brunswick',
        'SK' => 'Saskatchewan',
        'AB' => 'Alberta'
    } };

our $_country_list = {
    'BVT' => {
        'code2'           => 'BV',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => undef,
        'full_name'       => 'Bouvet Island',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_bouvetIsland'
    },
    'BMU' => {
        'code2'           => 'BM',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Bermuda',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_bermuda'
    },
    'NER' => {
        'code2'           => 'NE',
        'loadzone'        => 'us',
        'country_code'    => '227',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Niger',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_niger'
    },
    'NGA' => {
        'code2'           => 'NG',
        'loadzone'        => 'us',
        'country_code'    => '234',
        'dialing_code'    => [ '009' ],
        'full_name'       => 'Nigeria',
        'opermode'        => 'NIGERIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_nigeria'
    },
    'PLW' => {
        'code2'           => 'PW',
        'loadzone'        => 'us',
        'country_code'    => '680',
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Palau',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_palau'
    },
    'NZL' => {
        'station_prefix'  => '',
        'code2'           => 'NZ',
        'loadzone'        => 'nz',
        'template'        => '64000000000',
        'country_code'    => '64',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'New Zealand',
        'opermode'        => 'NEWZEALAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_newZealand'
    },
    'BIH' => {
        'code2'           => 'BA',
        'loadzone'        => 'us',
        'country_code'    => '387',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Bosnia And Herzegovina',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_bosniaAndHerzegovina'
    },
    'MCO' => {
        'code2'           => 'MC',
        'loadzone'        => 'us',
        'country_code'    => '377',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Monaco',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_monaco'
    },
    'TUV' => {
        'code2'           => 'TV',
        'loadzone'        => 'us',
        'country_code'    => '688',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Tuvalu',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_tuvalu'
    },
    'PRY' => {
        'code2'           => 'PY',
        'loadzone'        => 'us',
        'country_code'    => '595',
        'dialing_code'    => [ '002' ],
        'full_name'       => 'Paraguay',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_paraguay'
    },
    'FJI' => {
        'code2'           => 'FJ',
        'loadzone'        => 'us',
        'country_code'    => '679',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Fiji',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_fiji'
    },
    'GRL' => {
        'code2'           => 'GL',
        'loadzone'        => 'us',
        'country_code'    => '299',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Greenland',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_greenland'
    },
    'MWI' => {
        'code2'           => 'MW',
        'loadzone'        => 'us',
        'country_code'    => '265',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Malawi',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_malawi'
    },
    'GRC' => {
        'code2'           => 'GR',
        'loadzone'        => 'gr',
        'country_code'    => '30',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Greece',
        'opermode'        => 'GREECE',
        'national_prefix' => undef,
        'netsuite_name'   => '_greece'
    },
    'NAM' => {
        'code2'           => 'NA',
        'loadzone'        => 'us',
        'country_code'    => '264',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Namibia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_namibia'
    },
    'QAT' => {
        'code2'           => 'QA',
        'loadzone'        => 'us',
        'country_code'    => '974',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Qatar',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_qatar'
    },
    'DEU' => {
        'code2'           => 'DE',
        'loadzone'        => 'us',
        'country_code'    => '49',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Germany',
        'opermode'        => 'GERMANY',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_germany'
    },
    'MNG' => {
        'code2'           => 'MN',
        'loadzone'        => 'us',
        'country_code'    => '976',
        'dialing_code'    => [ '001' ],
        'full_name'       => 'Mongolia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_mongolia'
    },
    'ALB' => {
        'code2'           => 'AL',
        'loadzone'        => 'us',
        'country_code'    => '355',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Albania',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_albania'
    },
    'TGO' => {
        'code2'           => 'TG',
        'loadzone'        => 'us',
        'country_code'    => '228',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Togo',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_togo'
    },
    'CHE' => {
        'code2'           => 'CH',
        'loadzone'        => 'us',
        'country_code'    => '41',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Switzerland',
        'opermode'        => 'SWITZERLAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_switzerland'
    },
    'AUT' => {
        'code2'           => 'AT',
        'loadzone'        => 'at',
        'country_code'    => '43',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Austria',
        'opermode'        => 'AUSTRIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_austria'
    },
    'SUR' => {
        'code2'           => 'SR',
        'loadzone'        => 'us',
        'country_code'    => '597',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Suriname',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_suriname'
    },
    'CAN' => {
        'code2'           => 'CA',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Canada',
        'postal_code'     => '1',
        'opermode'        => 'CANADA',
        'national_prefix' => [ '1' ],
        'state_prov'      => '1',
        'netsuite_name'   => '_canada'
    },
    'CPV' => {
        'code2'           => 'CV',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '0' ],
        'full_name'       => 'Cape Verde',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_capVerde'
    },
    'GMB' => {
        'code2'           => 'GM',
        'loadzone'        => 'us',
        'country_code'    => '220',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Gambia',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_gambia'
    },
    'BGR' => {
        'code2'           => 'BG',
        'loadzone'        => 'us',
        'country_code'    => '359',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Bulgaria',
        'opermode'        => 'BULGARIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_bulgaria'
    },
    'THA' => {
        'code2'           => 'TH',
        'loadzone'        => 'us',
        'country_code'    => '66',
        'dialing_code'    => [ '001', '008', '009' ],
        'full_name'       => 'Thailand',
        'opermode'        => 'THAILAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_thailand'
    },
    'COL' => {
        'code2'           => 'CO',
        'loadzone'        => 'us',
        'country_code'    => '57',
        'dialing_code'    => [ '005', '007', '009' ],
        'full_name'       => 'Colombia',
        'opermode'        => 'COLUMBIA',
        'national_prefix' => [ '03', '05', '07', '09' ],
        'netsuite_name'   => '_colombia'
    },
    'CRI' => {
        'code2'           => 'CR',
        'loadzone'        => 'us',
        'country_code'    => '506',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Costa Rica',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_costaRica'
    },
    'MLT' => {
        'code2'           => 'MT',
        'loadzone'        => 'us',
        'country_code'    => '356',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Malta',
        'opermode'        => 'MALTA',
        'national_prefix' => [ '21' ],
        'netsuite_name'   => '_malta'
    },
    'SVK' => {
        'code2'           => 'SK',
        'loadzone'        => 'us',
        'country_code'    => '421',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Slovakia',
        'opermode'        => 'SLOVAKIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_slovakRepublic'
    },
    'LUX' => {
        'code2'           => 'LU',
        'loadzone'        => 'us',
        'country_code'    => '352',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Luxembourg',
        'opermode'        => 'LUXEMBOURG',
        'national_prefix' => undef,
        'netsuite_name'   => '_luxembourg'
    },
    'SLE' => {
        'code2'           => 'SL',
        'loadzone'        => 'us',
        'country_code'    => '232',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Sierra Leone',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_sierraLeone'
    },
    'MYS' => {
        'code2'           => 'MY',
        'loadzone'        => 'us',
        'country_code'    => '60',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Malaysia',
        'opermode'        => 'MALAYSIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_malaysia'
    },
    'TCD' => {
        'code2'           => 'TD',
        'loadzone'        => 'us',
        'country_code'    => '235',
        'dialing_code'    => [ '15' ],
        'full_name'       => 'Chad',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_chad'
    },
    'ESH' => {
        'code2'           => 'EH',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => undef,
        'full_name'       => 'Western Sahara',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_westernSahara'
    },
    'PRI' => {
        'code2'           => 'PR',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Puerto Rico',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_puertoRico'
    },
    'ITA' => {
        'code2'           => 'IT',
        'loadzone'        => 'it',
        'country_code'    => '39',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Italy',
        'opermode'        => 'ITALY',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_italy'
    },
    'LTU' => {
        'code2'           => 'LT',
        'loadzone'        => 'us',
        'country_code'    => '370',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Lithuania',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_lithuania'
    },
    'SGP' => {
        'code2'           => 'SG',
        'loadzone'        => 'us',
        'country_code'    => '65',
        'dialing_code'    => [ '001', '002', '008', '013', '018', '019' ],
        'full_name'       => 'Singapore',
        'opermode'        => 'SINGAPORE',
        'national_prefix' => undef,
        'netsuite_name'   => '_singapore'
    },
    'TUR' => {
        'code2'           => 'TR',
        'loadzone'        => 'us',
        'country_code'    => '90',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Turkey',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_turkey'
    },
    'FRA' => {
        'code2'           => 'FR',
        'loadzone'        => 'fr',
        'country_code'    => '33',
        'dialing_code'    => [ '00', '40', '50', '70', '90' ],
        'full_name'       => 'France',
        'opermode'        => 'FRANCE',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_france'
    },
    'MDG' => {
        'code2'           => 'MG',
        'loadzone'        => 'us',
        'country_code'    => '261',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Madagascar',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_madagascar'
    },
    'OMN' => {
        'code2'           => 'OM',
        'loadzone'        => 'us',
        'country_code'    => '968',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Oman',
        'opermode'        => 'OMAN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_oman'
    },
    'BTN' => {
        'code2'           => 'BT',
        'loadzone'        => 'us',
        'country_code'    => '975',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Bhutan',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_bhutan'
    },
    'EST' => {
        'code2'           => 'EE',
        'loadzone'        => 'us',
        'country_code'    => '372',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Estonia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_estonia'
    },
    'AIA' => {
        'code2'           => 'AI',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Anguilla',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_anguilla'
    },
    'KEN' => {
        'code2'           => 'KE',
        'loadzone'        => 'us',
        'country_code'    => '254',
        'dialing_code'    => [ '000', '006', '007' ],
        'full_name'       => 'Kenya',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_kenya'
    },
    'ATG' => {
        'code2'           => 'AG',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Antigua And Barbuda',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_antiguaAndBarbuda'
    },
    'BRB' => {
        'code2'           => 'BB',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Barbados',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_barbados'
    },
    'TMP' => {
        'code2'           => 'TP',
        'loadzone'        => 'us',
        'country_code'    => '670',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'East Timor',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_eastTimor'
    },
    'GEO' => {
        'code2'           => 'GE',
        'loadzone'        => 'us',
        'country_code'    => '995',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Georgia',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_georgia'
    },
    'TJK' => {
        'code2'           => 'TJ',
        'loadzone'        => 'us',
        'country_code'    => '992',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Tajikistan',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_tajikistan'
    },
    'BEN' => {
        'code2'           => 'BJ',
        'loadzone'        => 'us',
        'country_code'    => '229',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Benin',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_benin'
    },
    'MRT' => {
        'code2'           => 'MR',
        'loadzone'        => 'us',
        'country_code'    => '222',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Mauritania',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_mauritania'
    },
    'CYP' => {
        'code2'           => 'CY',
        'loadzone'        => 'us',
        'country_code'    => '357',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Cyprus',
        'opermode'        => 'CYRPUS',
        'national_prefix' => undef,
        'netsuite_name'   => '_cyprus'
    },
    'MHL' => {
        'code2'           => 'MH',
        'loadzone'        => 'us',
        'country_code'    => '692',
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Marshall Islands',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_marshallIslands'
    },
    'PAK' => {
        'code2'           => 'PK',
        'loadzone'        => 'us',
        'country_code'    => '92',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Pakistan',
        'opermode'        => 'PAKISTAN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_pakistan'
    },
    'ERI' => {
        'code2'           => 'ER',
        'loadzone'        => 'us',
        'country_code'    => '291',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Eritrea',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_eritrea'
    },
    'PNG' => {
        'code2'           => 'PG',
        'loadzone'        => 'us',
        'country_code'    => '675',
        'dialing_code'    => [ '05' ],
        'full_name'       => 'Papua New Guinea',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_papuaNewGuinea'
    },
    'LVA' => {
        'code2'           => 'LV',
        'loadzone'        => 'us',
        'country_code'    => '371',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Latvia',
        'opermode'        => 'LATVIA',
        'national_prefix' => undef,
        'netsuite_name'   => '_latvia'
    },
    'BOL' => {
        'code2'           => 'BO',
        'loadzone'        => 'us',
        'country_code'    => '591',
        'dialing_code'    => [ '0010', '0011', '0012', '0013' ],
        'full_name'       => 'Bolivia',
        'opermode'        => undef,
        'national_prefix' => [ '010', '011', '012', '013' ],
        'netsuite_name'   => '_bolivia'
    },
    'SJM' => {
        'code2'           => 'SJ',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => undef,
        'full_name'       => 'Svalbard And Jan Mayen Islands',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_svalbardAndJanMayenIslands'
    },
    'TKL' => {
        'code2'           => 'TK',
        'loadzone'        => 'us',
        'country_code'    => '690',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Tokelau',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_tokelau'
    },
    'ECU' => {
        'code2'           => 'EC',
        'loadzone'        => 'us',
        'country_code'    => '593',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Ecuador',
        'opermode'        => 'ECUADOR',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_ecuador'
    },
    'BDI' => {
        'code2'           => 'BI',
        'loadzone'        => 'us',
        'country_code'    => '257',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Burundi',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_burundi'
    },
    'AND' => {
        'code2'           => 'AD',
        'loadzone'        => 'us',
        'country_code'    => '376',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Andorra',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_andorra'
    },
    'NIC' => {
        'code2'           => 'NI',
        'loadzone'        => 'us',
        'country_code'    => '505',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Nicaragua',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_nicaragua'
    },
    'DMA' => {
        'code2'           => 'DM',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Dominica',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_dominica'
    },
    'MSR' => {
        'code2'           => 'MS',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Montserrat',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_montserrat'
    },
    'KAZ' => {
        'code2'           => 'KZ',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Kazakhstan',
        'opermode'        => 'KAZAKHSTAN',
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_kazakhstan'
    },
    'CHL' => {
        'code2'           => 'CL',
        'loadzone'        => 'cl',
        'country_code'    => '56',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Chile',
        'opermode'        => 'CHILE',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_chile'
    },
    'MMR' => {
        'code2'           => 'MM',
        'loadzone'        => 'us',
        'country_code'    => '95',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Myanmar',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_myanmar'
    },
    'CYM' => {
        'code2'           => 'KY',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Cayman Islands',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_caymanIslands'
    },
    'VUT' => {
        'code2'           => 'VU',
        'loadzone'        => 'us',
        'country_code'    => '678',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Vanuatu',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_vanuatu'
    },
    'GAB' => {
        'code2'           => 'GA',
        'loadzone'        => 'us',
        'country_code'    => '241',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Gabon',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_gabon'
    },
    'GBR' => {
        'station_prefix'  => undef,
        'code2'           => 'GB',
        'loadzone'        => 'uk',
        'template'        => '4400000000000',
        'country_code'    => '44',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'United Kingdom',
        'opermode'        => 'UK',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_unitedKingdomGB'
    },
    'BHS' => {
        'code2'           => 'BS',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Bahamas',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_bahamas'
    },
    'VNM' => {
        'code2'           => 'VN',
        'loadzone'        => 'us',
        'country_code'    => '84',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Viet Nam',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_vietnam'
    },
    'YEM' => {
        'code2'           => 'YE',
        'loadzone'        => 'us',
        'country_code'    => '967',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Yemen',
        'opermode'        => 'YEMEN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_yemen'
    },
    'AUS' => {
        'station_prefix'  => undef,
        'code2'           => 'AU',
        'loadzone'        => 'au',
        'template'        => '610000000000',
        'country_code'    => '61',
        'dialing_code'    => [ '0011', '0018' ],
        'full_name'       => 'Australia',
        'opermode'        => 'AUSTRALIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_australia',
        'state_prov'      => '1'
    },
    'DZA' => {
        'code2'           => 'DZ',
        'loadzone'        => 'us',
        'country_code'    => '213',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Algeria',
        'opermode'        => undef,
        'national_prefix' => [ '7' ],
        'netsuite_name'   => '_algeria'
    },
    'MTQ' => {
        'code2'           => 'MQ',
        'loadzone'        => 'us',
        'country_code'    => '596',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Martinique',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_martinique'
    },
    'YUG' => {
        'code2'           => 'YU',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => undef,
        'full_name'       => 'Yugoslavia',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_yugoslavia'
    },
    'PER' => {
        'code2'           => 'PE',
        'loadzone'        => 'us',
        'country_code'    => '51',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Peru',
        'opermode'        => 'PERU',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_peru'
    },
    'NPL' => {
        'code2'           => 'NP',
        'loadzone'        => 'us',
        'country_code'    => '977',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Nepal',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_nepal'
    },
    'GHA' => {
        'code2'           => 'GH',
        'loadzone'        => 'us',
        'country_code'    => '233',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Ghana',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_ghana'
    },
    'AZE' => {
        'code2'           => 'AZ',
        'loadzone'        => 'us',
        'country_code'    => '994',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Azerbaijan',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_azerbaijan'
    },
    'GIB' => {
        'code2'           => 'GI',
        'loadzone'        => 'us',
        'country_code'    => '350',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Gibraltar',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_gibraltar'
    },
    'GRD' => {
        'code2'           => 'GD',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Grenada',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_grenada'
    },
    'NIU' => {
        'code2'           => 'NU',
        'loadzone'        => 'us',
        'country_code'    => '683',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Niue',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_niue'
    },
    'SVN' => {
        'code2'           => 'SI',
        'loadzone'        => 'us',
        'country_code'    => '386',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Slovenia',
        'opermode'        => 'SLOVENIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_slovenia'
    },
    'MAC' => {
        'code2'           => 'MO',
        'loadzone'        => 'us',
        'country_code'    => '853',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Macau',
        'opermode'        => 'MACAO',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_macau'
    },
    'ARG' => {
        'code2'           => 'AR',
        'loadzone'        => 'us',
        'country_code'    => '54',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Argentina',
        'opermode'        => 'ARGENTINA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_argentina'
    },
    'LCA' => {
        'code2'           => 'LC',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Saint Lucia',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_saintLucia'
    },
    'IRL' => {
        'code2'           => 'IE',
        'loadzone'        => 'us',
        'country_code'    => '353',
        'dialing_code'    => [ '00', '048' ],
        'full_name'       => 'Ireland',
        'opermode'        => 'IRELAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_ireland'
    },
    'GNQ' => {
        'code2'           => 'GQ',
        'loadzone'        => 'us',
        'country_code'    => '240',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Equatorial Guinea',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_equatorialGuinea'
    },
    'VEN' => {
        'code2'           => 'VE',
        'loadzone'        => 'us',
        'country_code'    => '58',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Venezuela',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_venezuela'
    },
    'SOM' => {
        'code2'           => 'SO',
        'loadzone'        => 'us',
        'country_code'    => '252',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Somalia',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_somalia'
    },
    'ISR' => {
        'code2'           => 'IL',
        'loadzone'        => 'us',
        'country_code'    => '972',
        'dialing_code'    => [ '00', '012', '013', '014' ],
        'full_name'       => 'Israel',
        'opermode'        => 'ISRAEL',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_israel'
    },
    'HTI' => {
        'code2'           => 'HT',
        'loadzone'        => 'us',
        'country_code'    => '509',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Haiti',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_haiti'
    },
    'LBN' => {
        'code2'           => 'LB',
        'loadzone'        => 'us',
        'country_code'    => '961',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Lebanon',
        'opermode'        => 'LEBANON',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_lebanon'
    },
    'ZAF' => {
        'code2'           => 'ZA',
        'loadzone'        => 'za',
        'country_code'    => '27',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'South Africa',
        'opermode'        => 'SOUTHAFRICA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_southAfrica'
    },
    'UZB' => {
        'code2'           => 'UZ',
        'loadzone'        => 'us',
        'country_code'    => '998',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Uzbekistan',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_uzbekistan'
    },
    'NFK' => {
        'code2'           => 'NF',
        'loadzone'        => 'us',
        'country_code'    => '672',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Norfolk Island',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_norfolkIsland'
    },
    'NRU' => {
        'code2'           => 'NR',
        'loadzone'        => 'us',
        'country_code'    => '674',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Nauru',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_nauru'
    },
    'ASM' => {
        'code2'           => 'AS',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '11' ],
        'full_name'       => 'American Samoa',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_americanSamoa'
    },
    'KNA' => {
        'code2'           => 'KN',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Saint Kitts And Nevis',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_saintKittsAndNevis'
    },
    'LSO' => {
        'code2'           => 'LS',
        'loadzone'        => 'us',
        'country_code'    => '266',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Lesotho',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_lesotho'
    },
    'MNP' => {
        'code2'           => 'MP',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Northern Mariana Islands',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_northernMarianaIslands'
    },
    'SAU' => {
        'code2'           => 'SA',
        'loadzone'        => 'us',
        'country_code'    => '966',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Saudi Arabia',
        'opermode'        => 'SAUDIARABIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_saudiArabia'
    },
    'GIN' => {
        'code2'           => 'GN',
        'loadzone'        => 'us',
        'country_code'    => '224',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Guinea',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_guinea'
    },
    'NCL' => {
        'code2'           => 'NC',
        'loadzone'        => 'us',
        'country_code'    => '687',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'New Caledonia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_newCaledonia'
    },
    'COM' => {
        'code2'           => 'KM',
        'loadzone'        => 'us',
        'country_code'    => '269',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Comoros',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_comoros'
    },
    'RWA' => {
        'code2'           => 'RW',
        'loadzone'        => 'us',
        'country_code'    => '250',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Rwanda',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_rwanda'
    },
    'BEL' => {
        'code2'           => 'BE',
        'loadzone'        => 'us',
        'country_code'    => '32',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Belgium',
        'opermode'        => 'BELGIUM',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_belgium'
    },
    'CMR' => {
        'code2'           => 'CM',
        'loadzone'        => 'us',
        'country_code'    => '237',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Cameroon',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_cameroon'
    },
    'ARM' => {
        'code2'           => 'AM',
        'loadzone'        => 'us',
        'country_code'    => '374',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Armenia',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_armenia'
    },
    'HND' => {
        'code2'           => 'HN',
        'loadzone'        => 'us',
        'country_code'    => '504',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Honduras',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_honduras'
    },
    'JOR' => {
        'code2'           => 'JO',
        'loadzone'        => 'us',
        'country_code'    => '962',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Jordan',
        'opermode'        => 'JORDAN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_jordan'
    },
    'TUN' => {
        'code2'           => 'TN',
        'loadzone'        => 'us',
        'country_code'    => '216',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Tunisia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_tunisia'
    },
    'TON' => {
        'code2'           => 'TO',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Tonga',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_tonga'
    },
    'MLI' => {
        'code2'           => 'ML',
        'loadzone'        => 'us',
        'country_code'    => '223',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Mali',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_mali'
    },
    'SLV' => {
        'code2'           => 'SV',
        'loadzone'        => 'us',
        'country_code'    => '503',
        'dialing_code'    => [ '00', '14400' ],
        'full_name'       => 'El Salvador',
        'opermode'        => 'ELSALVADOR',
        'national_prefix' => undef,
        'netsuite_name'   => '_elSalvador'
    },
    'POL' => {
        'code2'           => 'PL',
        'loadzone'        => 'pl',
        'country_code'    => '48',
        'dialing_code'    => [ '0' ],
        'full_name'       => 'Poland',
        'opermode'        => 'POLAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_poland'
    },
    'LIE' => {
        'code2'           => 'LI',
        'loadzone'        => 'us',
        'country_code'    => '423',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Liechtenstein',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_liechtenstein'
    },
    'MUS' => {
        'code2'           => 'MU',
        'loadzone'        => 'us',
        'country_code'    => '230',
        'dialing_code'    => [ '020' ],
        'full_name'       => 'Mauritius',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_mauritius'
    },
    'KHM' => {
        'code2'           => 'KH',
        'loadzone'        => 'us',
        'country_code'    => '855',
        'dialing_code'    => [ '001' ],
        'full_name'       => 'Cambodia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_cambodia'
    },
    'IRQ' => {
        'code2'           => 'IQ',
        'loadzone'        => 'us',
        'country_code'    => '964',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Iraq',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_iraq'
    },
    'COG' => {
        'code2'           => 'CG',
        'loadzone'        => 'us',
        'country_code'    => '242',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Congo',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_congoRepublicOf'
    },
    'SYC' => {
        'code2'           => 'SC',
        'loadzone'        => 'us',
        'country_code'    => '248',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Seychelles',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_seychelles'
    },
    'SMR' => {
        'code2'           => 'SM',
        'loadzone'        => 'us',
        'country_code'    => '378',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'San Marino',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_sanMarino'
    },
    'BLR' => {
        'code2'           => 'BY',
        'loadzone'        => 'us',
        'country_code'    => '375',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Belarus',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_belarus'
    },
    'FIN' => {
        'code2'           => 'FI',
        'loadzone'        => 'us',
        'country_code'    => '358',
        'dialing_code'    => [ '00', '990', '994', '999' ],
        'full_name'       => 'Finland',
        'opermode'        => 'FINLAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_finland'
    },
    'BRA' => {
        'code2'           => 'BR',
        'loadzone'        => 'br',
        'country_code'    => '55',
        'dialing_code'    => [ '0014', '0015', '0021', '0023', '0031' ],
        'full_name'       => 'Brazil',
        'opermode'        => 'BRAZIL',
        'national_prefix' => [ '0', '014', '015', '021', '023', '031' ],
        'netsuite_name'   => '_brazil'
    },
    'HRV' => {
        'code2'           => 'HR',
        'loadzone'        => 'us',
        'country_code'    => '385',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Croatia',
        'opermode'        => 'CROATIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_croatiaHrvatska'
    },
    'ISL' => {
        'code2'           => 'IS',
        'loadzone'        => 'us',
        'country_code'    => '354',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Iceland',
        'opermode'        => 'ICELAND',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_iceland'
    },
    'PYF' => {
        'code2'           => 'PF',
        'loadzone'        => 'us',
        'country_code'    => '689',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'French Polynesia',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_frenchPolynesia'
    },
    'SWE' => {
        'code2'           => 'SE',
        'loadzone'        => 'us',
        'country_code'    => '46',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Sweden',
        'opermode'        => 'SWEDEN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_sweden'
    },
    'DOM' => {
        'code2'           => 'DO',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Dominican Republic',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_dominicanRepublic'
    },
    'PAN' => {
        'code2'           => 'PA',
        'loadzone'        => 'us',
        'country_code'    => '507',
        'dialing_code'    => [ '00', '08800', '05500' ],
        'full_name'       => 'Panama',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_panama'
    },
    'BLZ' => {
        'code2'           => 'BZ',
        'loadzone'        => 'us',
        'country_code'    => '501',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Belize',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_belize'
    },
    'CUB' => {
        'code2'           => 'CU',
        'loadzone'        => 'us',
        'country_code'    => '53',
        'dialing_code'    => [ '119' ],
        'full_name'       => 'Cuba',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_cuba'
    },
    'GLP' => {
        'code2'           => 'GP',
        'loadzone'        => 'us',
        'country_code'    => '590',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Guadeloupe',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_guadeloupe'
    },
    'HUN' => {
        'code2'           => 'HU',
        'loadzone'        => 'us',
        'country_code'    => '36',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Hungary',
        'opermode'        => 'HUNGARY',
        'national_prefix' => [ '06' ],
        'netsuite_name'   => '_hungary'
    },
    'MEX' => {
        'code2'           => 'MX',
        'loadzone'        => 'mx',
        'country_code'    => '52',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Mexico',
        'opermode'        => 'MEXICO',
        'national_prefix' => [ '01' ],
        'netsuite_name'   => '_mexico'
    },
    'GUF' => {
        'code2'           => 'GF',
        'loadzone'        => 'us',
        'country_code'    => '594',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'French Guiana',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_frenchGuiana'
    },
    'DNK' => {
        'code2'           => 'DK',
        'loadzone'        => 'us',
        'country_code'    => '45',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Denmark',
        'opermode'        => 'DENMARK',
        'national_prefix' => undef,
        'netsuite_name'   => '_denmark'
    },
    'KWT' => {
        'code2'           => 'KW',
        'loadzone'        => 'us',
        'country_code'    => '965',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Kuwait',
        'opermode'        => 'KUWAIT',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_kuwait'
    },
    'ZMB' => {
        'code2'           => 'ZM',
        'loadzone'        => 'us',
        'country_code'    => '260',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Zambia',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_zambia'
    },
    'PRT' => {
        'code2'           => 'PT',
        'loadzone'        => 'us',
        'country_code'    => '351',
        'dialing_code'    => [ '00', '882' ],
        'full_name'       => 'Portugal',
        'opermode'        => 'PORTUGAL',
        'national_prefix' => undef,
        'netsuite_name'   => '_portugal'
    },
    'IND' => {
        'code2'           => 'IN',
        'loadzone'        => 'us',
        'country_code'    => '91',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'India',
        'opermode'        => 'INDIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_india'
    },
    'DJI' => {
        'code2'           => 'DJ',
        'loadzone'        => 'us',
        'country_code'    => '253',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Djibouti',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_djibouti'
    },
    'JPN' => {
        'station_prefix'  => '0',
        'code2'           => 'JP',
        'loadzone'        => 'jp',
        'template'        => '8100000000000',
        'country_code'    => '81',
        'dialing_code'    => [ '010', '001', '0061', '0041' ],
        'full_name'       => 'Japan',
        'opermode'        => 'JAPAN',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_japan'
    },
    'UGA' => {
        'code2'           => 'UG',
        'loadzone'        => 'us',
        'country_code'    => '256',
        'dialing_code'    => [ '007' ],
        'full_name'       => 'Uganda',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_uganda'
    },
    'URY' => {
        'code2'           => 'UY',
        'loadzone'        => 'us',
        'country_code'    => '598',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Uruguay',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_uruguay'
    },
    'BWA' => {
        'code2'           => 'BW',
        'loadzone'        => 'us',
        'country_code'    => '267',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Botswana',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_botswana'
    },
    'GUY' => {
        'code2'           => 'GY',
        'loadzone'        => 'us',
        'country_code'    => '592',
        'dialing_code'    => [ '001' ],
        'full_name'       => 'Guyana',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_guyana'
    },
    'CHN' => {
        'code2'           => 'CN',
        'loadzone'        => 'us',
        'country_code'    => '86',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'China',
        'opermode'        => 'CHINA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_china'
    },
    'TCA' => {
        'code2'           => 'TC',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Turks And Caicos Islands',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_turksAndCaicosIslands'
    },
    'STP' => {
        'code2'           => 'ST',
        'loadzone'        => 'us',
        'country_code'    => '239',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Sao Tome And Principe',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_saoTomeAndPrincipe'
    },
    'PHL' => {
        'code2'           => 'PH',
        'loadzone'        => 'us',
        'country_code'    => '63',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Philippines',
        'opermode'        => 'PHILIPPINES',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_philippines'
    },
    'BHR' => {
        'code2'           => 'BH',
        'loadzone'        => 'us',
        'country_code'    => '973',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Bahrain',
        'opermode'        => 'BAHRAIN',
        'national_prefix' => undef,
        'netsuite_name'   => '_bahrain'
    },
    'ABW' => {
        'code2'           => 'AW',
        'loadzone'        => 'us',
        'country_code'    => '297',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Aruba',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_aruba'
    },
    'NOR' => {
        'code2'           => 'NO',
        'loadzone'        => 'no',
        'country_code'    => '47',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Norway',
        'opermode'        => 'NORWAY',
        'national_prefix' => undef,
        'netsuite_name'   => '_norway'
    },
    'NLD' => {
        'code2'           => 'NL',
        'loadzone'        => 'nl',
        'country_code'    => '31',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Netherlands',
        'opermode'        => 'NETHERLANDS',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_netherlands'
    },
    'MAR' => {
        'code2'           => 'MA',
        'loadzone'        => 'us',
        'country_code'    => '212',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Morocco',
        'opermode'        => 'MOROCCO',
        'national_prefix' => undef,
        'netsuite_name'   => '_morocco'
    },
    'ESP' => {
        'code2'           => 'ES',
        'loadzone'        => 'us',
        'country_code'    => '34',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Spain',
        'opermode'        => 'SPAIN',
        'national_prefix' => [ '9' ],
        'netsuite_name'   => '_spain'
    },
    'MOZ' => {
        'code2'           => 'MZ',
        'loadzone'        => 'us',
        'country_code'    => '258',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Mozambique',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_mozambique'
    },
    'VCT' => {
        'code2'           => 'VC',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Saint Vincent And The Grenadines',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_saintVincentAndTheGrenadines'
    },
    'TTO' => {
        'code2'           => 'TT',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Trinidad And Tobago',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_trinidadAndTobago'
    },
    'CAF' => {
        'code2'           => 'CF',
        'loadzone'        => 'us',
        'country_code'    => '236',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Central African Republic',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_centralAfricanRepublic'
    },
    'ROM' => {
        'code2'           => 'RO',
        'loadzone'        => 'us',
        'country_code'    => '40',
        'dialing_code'    => [ '00', '18' ],
        'full_name'       => 'Romania',
        'opermode'        => 'ROMANIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_romania'
    },
    'BGD' => {
        'code2'           => 'BD',
        'loadzone'        => 'us',
        'country_code'    => '880',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Bangladesh',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_bangladesh'
    },
    'SDN' => {
        'code2'           => 'SD',
        'loadzone'        => 'us',
        'country_code'    => '249',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Sudan',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_sudan'
    },
    'COK' => {
        'code2'           => 'CK',
        'loadzone'        => 'us',
        'country_code'    => '682',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Cook Islands',
        'opermode'        => undef,
        'national_prefix' => [ '00' ],
        'netsuite_name'   => '_cookIslands'
    },
    'GUM' => {
        'code2'           => 'GU',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Guam',
        'opermode'        => 'GUAM',
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_guam'
    },
    'MDV' => {
        'code2'           => 'MV',
        'loadzone'        => 'us',
        'country_code'    => '960',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Maldives',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_maldives'
    },
    'AGO' => {
        'code2'           => 'AO',
        'loadzone'        => 'us',
        'country_code'    => '244',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Angola',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_angola'
    },
    'LKA' => {
        'code2'           => 'LK',
        'loadzone'        => 'us',
        'country_code'    => '94',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Sri Lanka',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_sriLanka'
    },
    'JAM' => {
        'code2'           => 'JM',
        'loadzone'        => 'us',
        'country_code'    => undef,
        'dialing_code'    => [ '011' ],
        'full_name'       => 'Jamaica',
        'opermode'        => undef,
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_jamaica'
    },
    'UKR' => {
        'code2'           => 'UA',
        'loadzone'        => 'us',
        'country_code'    => '380',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Ukraine',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_ukraine'
    },
    'ZWE' => {
        'code2'           => 'ZW',
        'loadzone'        => 'us',
        'country_code'    => '263',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Zimbabwe',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_zimbabwe'
    },
    'BFA' => {
        'code2'           => 'BF',
        'loadzone'        => 'us',
        'country_code'    => '226',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Burkina Faso',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_burkinaFaso'
    },
    'KIR' => {
        'code2'           => 'KI',
        'loadzone'        => 'us',
        'country_code'    => '686',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Kiribati',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_kiribati'
    },
    'USA' => {
        'station_prefix'  => undef,
        'code2'           => 'US',
        'loadzone'        => 'us',
        'template'        => '10000000000',
        'country_code'    => '1',
        'dialing_code'    => [ '011' ],
        'full_name'       => 'United States',
        'postal_code'     => '1',
        'opermode'        => 'USA',
        'national_prefix' => [ '1' ],
        'netsuite_name'   => '_unitedStates',
        'state_prov'      => '1'
    },
    'EGY' => {
        'code2'           => 'EG',
        'loadzone'        => 'us',
        'country_code'    => '20',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Egypt',
        'opermode'        => 'EGYPT',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_egypt'
    },
    'SEN' => {
        'code2'           => 'SN',
        'loadzone'        => 'us',
        'country_code'    => '221',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Senegal',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_senegal'
    },
    'LBR' => {
        'code2'           => 'LR',
        'loadzone'        => 'us',
        'country_code'    => '231',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Liberia',
        'opermode'        => undef,
        'national_prefix' => [ '22' ],
        'netsuite_name'   => '_liberia'
    },
    'TKM' => {
        'code2'           => 'TM',
        'loadzone'        => 'us',
        'country_code'    => '993',
        'dialing_code'    => [ '810' ],
        'full_name'       => 'Turkmenistan',
        'opermode'        => undef,
        'national_prefix' => [ '8' ],
        'netsuite_name'   => '_turkmenistan'
    },
    'SWZ' => {
        'code2'           => 'SZ',
        'loadzone'        => 'us',
        'country_code'    => '268',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Swaziland',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_swaziland'
    },
    'SLB' => {
        'code2'           => 'SB',
        'loadzone'        => 'us',
        'country_code'    => '677',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Solomon Islands',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_solomonIslands'
    },
    'GTM' => {
        'code2'           => 'GT',
        'loadzone'        => 'us',
        'country_code'    => '502',
        'dialing_code'    => [ '00', '13000', '14700' ],
        'full_name'       => 'Guatemala',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_guatemala'
    },
    'CZE' => {
        'code2'           => 'CZ',
        'loadzone'        => 'us',
        'country_code'    => '420',
        'dialing_code'    => [ '00', '95200' ],
        'full_name'       => 'Czech Republic',
        'opermode'        => 'CZECH',
        'national_prefix' => undef,
        'netsuite_name'   => '_czechRepublic'
    },
    'IDN' => {
        'code2'           => 'ID',
        'loadzone'        => 'us',
        'country_code'    => '62',
        'dialing_code'    => [ '001', '007', '017' ],
        'full_name'       => 'Indonesia',
        'opermode'        => 'INDONESIA',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_indonesia'
    },
    'KGZ' => {
        'code2'           => 'KG',
        'loadzone'        => 'us',
        'country_code'    => '996',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Kyrgyzstan',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_kyrgyzstan'
    },
    'ARE' => {
        'code2'           => 'AE',
        'loadzone'        => 'us',
        'country_code'    => '971',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'United Arab Emirates',
        'opermode'        => 'UAE',
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_unitedArabEmirates'
    },
    'AFG' => {
        'code2'           => 'AF',
        'loadzone'        => 'us',
        'country_code'    => '93',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Afghanistan',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_afghanistan'
    },
    'BRN' => {
        'code2'           => 'BN',
        'loadzone'        => 'us',
        'country_code'    => '673',
        'dialing_code'    => [ '00' ],
        'full_name'       => 'Brunei Darussalam',
        'opermode'        => undef,
        'national_prefix' => [ '0' ],
        'netsuite_name'   => '_bruneiDarussalam'
    },
    'WLF' => {
        'code2'           => 'WF',
        'loadzone'        => 'us',
        'country_code'    => '681',
        'dialing_code'    => [ '19' ],
        'full_name'       => 'Wallis And Futuna Islands',
        'opermode'        => undef,
        'national_prefix' => undef,
        'netsuite_name'   => '_wallisAndFutunaIslands'
    } };

sub get_loadzone {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{loadzone};
    }
    return undef;
}

sub get_country_code {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{country_code};
    }
    return undef;
}

sub get_long_name {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{long_name};
    }
    return undef;
}

sub get_dialing_code {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{dialing_code};
    }
    return undef;
}

sub get_opermode {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{opermode};
    }
    return undef;
}

sub get_national_prefix {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{national_prefix};
    }
    return undef;
}

sub get_netsuite_name {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{netsuite_name};
    }
    return undef;
}

sub get_code2 {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{code2};
    }
    return undef;
}

sub get_full_name {
    my ( $class, $country_name ) = @_;
    if ( defined $_country_list->{$country_name} ) {
        return $_country_list->{$country_name}->{full_name};
    }
    return undef;
}
sub get_country_from_netsuite_name {
	my ($class,$netsuite_name)=@_;

	my ($iso3) = grep {$_country_list->{$_}->{netsuite_name} eq $netsuite_name} keys %$_country_list;
	return $iso3;
}
