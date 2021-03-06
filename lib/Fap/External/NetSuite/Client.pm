package Fap::External::NetSuite::Client;
$VERSION = '1.03';

use strict;
no warnings "all";

#use Fap::Synchronize;
use Carp;

#use SOAP::Lite +trace => "debug";
use SOAP::Lite;
use Data::Dumper;
use XML::Parser;
use XML::Parser::EasyTree;
use Time::HiRes;
$XML::Parser::EasyTree::Noempty = 1;
use Fap::External::NetSuite::Config;

use constant NETSUITE_LOCKFILE_DIR => '/nfs/netsuite_prov';
use constant DEFAULT_LOCKFILE      => 'serialization_gate';

sub new {
    my ( $self, $hash_ref ) = @_;

    for (qw(ROLE EMAIL PASSWORD ACCOUNT)) {
        croak "Can't initialize without value $_ in constructor!" if !defined $hash_ref->{$_};
    }
    my $soap = SOAP::Lite->new;
    $soap->outputxml('true');
    if ( $hash_ref->{SANDBOX} ) {
        $soap->proxy('https://webservices.sandbox.netsuite.com/services/NetSuitePort_2012_1');
    } else {
        $soap->proxy('https://webservices.netsuite.com/services/NetSuitePort_2012_1');
    }
    $soap->options( { compress_threshold => 10000 } );
    my $systemNamespaces = &Fap::External::NetSuite::Config::SystemNamespaces;
    for my $mapping ( keys %{$systemNamespaces} ) {
        $soap->serializer->register_ns( $systemNamespaces->{$mapping}, $mapping );
    }

    $hash_ref->{TIME} = time;
    $hash_ref->{SOAP} = $soap;

    $hash_ref->{RECORD_NAMESPACES} = &Fap::External::NetSuite::Config::RecordNamespaces;
    $hash_ref->{SEARCH_NAMESPACES} = &Fap::External::NetSuite::Config::SearchNamespaces;
    $hash_ref->{RECORD_TYPES}      = &Fap::External::NetSuite::Config::RecordTypes;
    $hash_ref->{SEARCH_TYPES}      = &Fap::External::NetSuite::Config::SearchTypes;
    $hash_ref->{RECORD_FIELDS}     = &Fap::External::NetSuite::Config::RecordFields;
    $hash_ref->{COUNTRY_LIST}      = &Fap::External::NetSuite::Config::CountryEnumerations;

    bless $hash_ref, $self;
    return $hash_ref;
}

sub synchronize {
    my $self = shift;
    return 0 unless ref( $self->{_sync} );
    return 1 if $self->{_sync}->is_synced();
    return $self->{_sync}->sync();
}

sub desynchronize {
    my $self = shift;
    return unless ref( $self->{_sync} );
    return $self->{_sync}->desync();
}

# Make sure we destroy the lock if we leave context
sub DESTROY {
    my $self = shift;


    $self->logout;
}

sub getRequest {
    my ($self) = shift;
    return $self->{LAST_REQ};
}

sub getResponse {
    my ($self) = shift;
    return $self->{LAST_RES};
}

sub getBody {
    my ($self) = shift;
    return $self->{LAST_BODY};
}

sub getHead {
    my ($self) = shift;
    return $self->{LAST_HEAD};
}

sub login {
    my ($self) = shift;

    $self->{SOAP}->on_action( sub { return 'login'; } );
    my $som = $self->handle_response(
        $self->{SOAP}->login(
            SOAP::Data->name(
                'passport' => \SOAP::Data->value(
                    SOAP::Data->name( 'email'    => $self->{EMAIL} ),
                    SOAP::Data->name( 'password' => $self->{PASSWORD} ),
                    SOAP::Data->name( 'account'  => $self->{ACCOUNT} ),
                    SOAP::Data->name('role')->attr( { 'internalId' => $self->{ROLE} } ) ) ) ) );
    if ($som) {
        $self->{COOKIE} = $self->{SOAP}->transport->http_response->header('Set-Cookie');
        {
            $som->{userId} = $som->{userIdInternalId};
        }

        return 0 if $som->{statusIsSuccess} ne 'true';
    } else {
        return 0;
    }

    $self->{LOGIN_RESULTS} = $som;
    return 1;
}

sub loginResults {
    my ($self) = shift;
    if   ( defined $self->{LOGIN_RESULTS} ) { return $self->{LOGIN_RESULTS}; }
    else                                    { return; }
}

sub logout {
    my ($self) = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'logout'; } );
    my $som = $self->{SOAP}->logout;

    # unlock the file
    #$self->desynchronize if $self->{locked};

    return 1;
}

sub logoutResults {
    my ($self) = shift;
    if   ( defined $self->{LOGOUT_RESULTS} ) { return $self->{LOGOUT_RESULTS}; }
    else                                     { return; }
}

sub getSelectValue {
    my ($self) = shift;
    my (%args) = @_;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'getSelectValue'; } );

    my $attr = { xmlns => "urn:messages_2012_1.platform.webservices.netsuite.com" };
    my $data = SOAP::Data->name(
        "fieldDescription" => \SOAP::Data->value(
            SOAP::Data->name( 'recordType' => $args{type} )    #->attr({xmlns=>"urn:core_2012_1.platform.webservices.netsuite.com"}),
                                                               #SOAP::Data->name('field'=>$args{type})->attr($attr)
          )->attr($attr) );
    return $self->{SOAP}->getSelectValue($data);

    my $som = $self->handle_response( $self->{SOAP}->getSelectValue($data) );

    #SOAP::Data->name('fieldName')->attr({ 'recordType' => $args{type}})
    #SOAP::Data->name('fieldName' => \SOAP::Data->name('searchCriteria')->value('misShipment')->prefix('core'))->attr({ 'fieldType' => $recordType })
    #));
    if ($som) { return $som; }
    return undef;
}

sub getCustomization {
    my ($self)       = shift;
    my ($recordType) = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'getCustomization'; } );
    my $data = SOAP::Data->type( xml => qq(<customizationType getCustomizationType="customList"/><includeInactives>false</includeInactives>) );

    #my $som = $self->handle_response($self->{SOAP}->getCustomization(
    #SOAP::Data->name('customizationType')->attr({ 'getCustomizationType' => $recordType })
    #));

    my $som = $self->handle_response( $self->{SOAP}->getCustomizationId($data) );

    if ($som) { return $som; }
    return undef;
}

sub getCustomizationId {
    my ( $self, $type ) = @_;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'getCustomizationId'; } );
    my $data =
      SOAP::Data->value( SOAP::Data->name("customizationType")->attr( { getCustomizationType => $type } ), SOAP::Data->name( "includeInactives" => "false" ), );
    my $som = $self->handle_response( $self->{SOAP}->getCustomizationId($data) );

    if ($som) { return $som; }
    return undef;
}

sub getList {
    my ( $self, $type, @ids ) = @_;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'getList'; } );
    my @yams;
    foreach (@ids) {
        push(
            @yams,
            SOAP::Data->name('baseRef')->attr( {
                    'internalId' => $_,
                    'type'       => $type,
                    'xsi:type'   => 'core:RecordRef'
                }
              )->prefix('messages') );
    }
    my $data = SOAP::Data->value(@yams);
    return $self->handle_response( $self->{SOAP}->getList($data) );
}

sub get {
    my $self             = shift;
    my $recordType       = shift;
    my $recordInternalId = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'get'; } );
    my $som = $self->handle_response(
        $self->{SOAP}->get(
            SOAP::Data->name('baseRef')->attr( {
                    'internalId' => $recordInternalId,
                    'type'       => $recordType,
                    'xsi:type'   => 'core:RecordRef'
                }
              )->prefix('messages') ) );
    if ($som) { return $som; }
    return undef;
}

sub getAll {
    my $self       = shift;
    my $recordType = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'getAll'; } );
    my $som = $self->handle_response( $self->{SOAP}->getAll( SOAP::Data->name('record')->attr( { 'recordType' => $recordType, } ) ) );
    if ($som) { return $som; }
    return undef;
}

sub getResults {
    my $self = shift;
    if   ( defined $self->{GET_RESULTS} ) { return $self->{GET_RESULTS}; }
    else                                  { return; }
}

sub search {
    my $self    = shift;
    my $type    = shift;
    my $request = shift;
    my $header  = shift;

    $header->{bodyFieldsOnly} = 'true' if !defined $header->{bodyFieldsOnly};
    $header->{pageSize}       = 10     if !defined $header->{pageSize};

    croak 'Non HASH reference passed to subroutine search!' if ref $request ne 'HASH';

    if ( $type !~ /Search$/ ) { $type = ucfirst($type) . 'Search'; }

    my $advanced      = 0;
    my $savedSearchId = '';
    my $rectype;
    undef my @searchRecord;
    for my $searchType ( keys %{$request} ) {

        # basic, customerJoin
        if ( $searchType eq 'advanced' ) {
            $advanced = 1;
        }
        undef my $searchSystemNamespace;
        undef my $searchTypeNamespace;

        if ( defined $self->{RECORD_TYPES}->{$type}->{$searchType} ) {
            $searchTypeNamespace = $self->{RECORD_TYPES}->{$type}->{$searchType};
        } else {
            croak "Search type $searchType is not defined in a $type search";
        }

        undef my @searchTypes;
        for my $searchElement ( @{ $request->{$searchType} } ) {

            # for advanced, only look for savedSearchId
            if ($advanced) {
                if ( $searchElement->{name} ne 'savedSearchId' ) {
                    next;
                } else {
                    $savedSearchId = $searchElement->{value};
                }
            }

            # parent, firstName, lastName
            undef my $searchValue;
            $searchElement->{prefix} = 'common';
            if ( $searchElement->{attr}->{internalId} ) {
                $searchElement->{attr}->{'xsi:type'} = 'core:RecordRef';
                push @searchTypes, SOAP::Data->new( %{$searchElement} );
                next;
            } else {
                my $searchElementType = $self->{SEARCH_TYPES}->{$searchTypeNamespace}->{ $searchElement->{name} };
                $searchElement->{attr}->{'xsi:type'} = 'core:' . $searchElementType;
                if ( $searchElementType eq 'SearchDateField' and $searchElement->{value} =~ /^\D+$/ ) {
                    $searchValue->{name} = 'predefinedSearchValue';
                }
            }

            # customFieldList
            if ( ref $searchElement->{value} eq 'ARRAY' ) {
                undef my @searchValues;

                # customField
                for my $searchValue ( @{ $searchElement->{value} } ) {
                    if ( ref $searchValue->{value} eq 'ARRAY' ) {
                        undef my @customFieldValues;
                        for my $customFieldValue ( @{ $searchValue->{value} } ) {
                            $customFieldValue->{prefix} = 'core'        if !defined $customFieldValue->{prefix};
                            $customFieldValue->{name}   = 'searchValue' if !defined $customFieldValue->{name};
                            push @customFieldValues, SOAP::Data->new( %{$customFieldValue} );
                        }
                        $searchValue->{value} = \SOAP::Data->value(@customFieldValues);
                        push @searchValues, SOAP::Data->new( %{$searchValue} );
                    } else {
                        $searchValue->{prefix} = 'core'        if !defined $searchValue->{prefix};
                        $searchValue->{name}   = 'searchValue' if !defined $searchValue->{name};
                        if ( $searchValue->{name} eq 'customField' ) {
                            my $customFieldValue = { name => 'searchValue', value => $searchValue->{value}, prefix => 'core' };
                            $searchValue->{value} = \SOAP::Data->new( %{$customFieldValue} );
                        } else {
                            if ( $searchValue->{attr}->{internalId} ) {
                                $searchValue->{attr}->{'xsi:type'} = 'core:RecordRef';
                            }
                        }
                        push @searchValues, SOAP::Data->new( %{$searchValue} );
                    }
                }
                $searchElement->{value} = \SOAP::Data->value(@searchValues);
                push @searchTypes, SOAP::Data->new( %{$searchElement} );
            } elsif ( defined( $searchElement->{recType} ) ) {
                $rectype = $searchElement->{recType};
            } else {
                $searchValue->{name}               = 'searchValue'           if !defined $searchValue->{name};
                $searchValue->{value}              = $searchElement->{value} if !defined $searchValue->{value};
                $searchValue->{prefix}             = 'core'                  if !defined $searchValue->{prefix};
                $searchValue->{attr}->{'xsi:type'} = 'core:RecordRef'        if $searchElement->{attr}->{internalId};
                $searchElement->{value}            = \SOAP::Data->new( %{$searchValue} );
                push @searchTypes, SOAP::Data->new( %{$searchElement} );
            }
        }

        if ( defined($rectype) ) {
            push @searchRecord,
              SOAP::Data->name( $searchType => \SOAP::Data->value(@searchTypes) )
              ->attr( { 'xsi:type' => 'common:' . $searchTypeNamespace, 'recType' => $rectype } );
        } else {
            push @searchRecord, SOAP::Data->name( $searchType => \SOAP::Data->value(@searchTypes) )->attr( { 'xsi:type' => 'common:' . $searchTypeNamespace } );
        }
    }

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'search'; } );

    my $som;
    if ($advanced) {
        $som = $self->handle_response(
            $self->{SOAP}->search(
                SOAP::Header->name(
                    'searchPreferences' => \SOAP::Header->value(
                        SOAP::Header->name('bodyFieldsOnly')->value( $header->{bodyFieldsOnly} )->prefix('messages'),
                        SOAP::Header->name('pageSize')->value( $header->{pageSize} )->prefix('messages'),
                    )
                  )->prefix('messages'),
                SOAP::Data->name('searchRecord')
                  ->attr( { 'xsi:type' => $self->{SEARCH_NAMESPACES}->{$type} . ':' . $type . 'Advanced', 'savedSearchId' => $savedSearchId } ) ) );
    } else {
        $som = $self->handle_response(
            $self->{SOAP}->search(
                SOAP::Header->name(
                    'searchPreferences' => \SOAP::Header->value(
                        SOAP::Header->name('bodyFieldsOnly')->value( $header->{bodyFieldsOnly} )->prefix('messages'),
                        SOAP::Header->name('pageSize')->value( $header->{pageSize} )->prefix('messages'),
                    )
                  )->prefix('messages'),
                SOAP::Data->name( 'searchRecord' => \SOAP::Data->value(@searchRecord) )
                  ->attr( { 'xsi:type' => $self->{SEARCH_NAMESPACES}->{$type} . ':' . $type } ) ) );
    }
    if ($som) {
        return $som;
    }
    return undef;
}

sub searchResults {
    my $self = shift;
    if   ( defined $self->{SEARCH_RESULTS} ) { return $self->{SEARCH_RESULTS}; }
    else                                     { return; }
}

sub searchMore {
    my $self      = shift;
    my $pageIndex = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'searchMore'; } );
    my $som = $self->handle_response( $self->{SOAP}->searchMore( SOAP::Data->name('pageIndex')->value($pageIndex)->prefix('messages') ) );
    if ($som) {
        return $som;
    }
    return undef;
}

sub searchNext {
    my $self = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'searchNext'; } );
    my $som = $self->handle_response( $self->{SOAP}->searchNext );
    if ($som) {
        return $som;
    }
    return undef;
}

sub delete {
    my $self             = shift;
    my $recordType       = shift;
    my $recordInternalId = shift;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'delete'; } );
    my $som = $self->handle_response(
        $self->{SOAP}->delete(
            SOAP::Data->name('baseRef')->attr( {
                    'internalId' => $recordInternalId,
                    'type'       => $recordType,
                    'xsi:type'   => 'core:RecordRef'
                } ) ) );
    if ($som) { return $som->{recordInternalId}; }
    return undef;
}

sub deleteList {
    my $self       = shift;
    my $recordType = shift;
    my @ids        = @_;

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'deleteList'; } );
    my @list;
    foreach my $id (@ids) {
        push( @list, \SOAP::Data->attr( { internalId => $id, type => $recordType, 'xsi:type' => 'core:RecordRef' } ) );
    }
    my $som = $self->handle_response( $self->{SOAP}->deleteList( SOAP::Data->type('DataArray')->name( 'baseRef' => @list ) ) );

    if ($som) {
        return $som;
    }
    return undef;
}

sub add {
    my $self       = shift;
    my $recordType = shift;
    my $recordRef  = shift;

    $self->error("Invalid recordType: $recordType!") if !defined $self->{RECORD_NAMESPACES}->{$recordType};

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );

    $self->{SOAP}->on_action( sub { return 'add'; } );

    my $som = $self->handle_response(
        $self->{SOAP}->add(
            SOAP::Data->name( 'record' => \SOAP::Data->value( $self->_parseRequest( ucfirst($recordType), $recordRef ) ) )
              ->attr( { 'xsi:type' => $self->{RECORD_NAMESPACES}->{$recordType} . ':' . ucfirst($recordType) } ) ) );

    if ($som) { return $som->{baseRefInternalId}; }
    return undef;
}

# work in progress
sub addList {
    my $self       = shift;
    my $recordType = shift;
    my $recordRef  = shift;

    $self->error("Invalid recordType: $recordType!") if !defined $self->{RECORD_NAMESPACES}->{$recordType};
    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'addList'; } );
    my $soapdata;
    foreach my $r ( @{$recordRef} ) {
        my $onedata =
          SOAP::Data->name( 'record' => \SOAP::Data->value( $self->_parseRequest( ucfirst($recordType), $r ) ) )
          ->attr( { 'xsi:type' => $self->{RECORD_NAMESPACES}->{$recordType} . ':' . ucfirst($recordType) } );
        push( @{$soapdata}, $onedata );
    }

    my $som = $self->handle_response( $self->{SOAP}->addList($soapdata) );
    if ($som) {
        return $som->{recordInternalId};
    }
    return undef;
}

sub update {
    my $self       = shift;
    my $recordType = shift;
    my $recordRef  = shift;
    my $replaceall = shift || 'false';

    my $internalId = $recordRef->{internalId};
    delete $recordRef->{internalId};

    $self->error("Invalid recordType: $recordType!") if !defined $self->{RECORD_NAMESPACES}->{$recordType};

    $self->{SOAP}->transport->http_request->header( Cookie => $self->{COOKIE} );
    $self->{SOAP}->on_action( sub { return 'update'; } );
    my $som = $self->handle_response(
        $self->{SOAP}->update(
            SOAP::Data->name( 'record' => \SOAP::Data->value( $self->_parseRequest( ucfirst($recordType), $recordRef, $replaceall ) ) )
              ->attr( { 'xsi:type' => $self->{RECORD_NAMESPACES}->{$recordType} . ':' . ucfirst($recordType), 'internalId' => $internalId } ) ) );

    if ($som) {
        return $som;
    }
    return undef;
}

sub _parseRequest {
    my $self        = shift;
    my $requestType = shift;
    my $requestRef  = shift;
    my $replaceall  = shift || 'false';


    undef my @requestSoap;
    while ( my ( $key, $value ) = each %{$requestRef} ) {

        if ( ref($value) eq "HASH" && defined $value->{soapData} ) {
            if ( ref( $value->{soapData} ) eq "ARRAY" ) {
                push( @requestSoap, SOAP::Data->name( $key => \SOAP::Data->value( @{ $value->{soapData} } ) ) );
            } else {
                push( @requestSoap, SOAP::Data->name( $key => $value->{soapData} ) );

            }

        } elsif ( ref $value eq 'ARRAY' ) {
            my $listElementName = $key;
            $listElementName =~ s/^(.*)List$/$1/;


            undef my @listElements;
            for my $listElement ( @{ $requestRef->{$key} } ) {

                undef my @sequence;
                # if the listElement is customField
                # handle it differently

                if ( $listElementName eq 'customField' ) {
		    push(@listElements,$self->_parseCustomList($listElement));
                } else {
                    while ( my ( $key, $value ) = each %{$listElement} ) {
			if ($key eq "customFieldList") {
				my @tmp=();
				foreach my $field (@$value) {
					push(@tmp,$self->_parseCustomList($field));
				}
				$value = \@tmp;# SOAP::Data->name($key=>\SOAP::Data->value(@tmp));
			}# else {
                        	push @sequence, $self->_parseRequestField( ucfirst $requestType . ucfirst $listElementName, $key, $value );
			#}
                    }
                    push @listElements, SOAP::Data->name( $listElementName => \SOAP::Data->value(@sequence) );
                }
            }
            if ( grep $_ eq $key, qw(addressbookList creditCardsList itemList) ) {
                push @requestSoap, SOAP::Data->name( $key => \SOAP::Data->value(@listElements) )->attr( { replaceAll => $replaceall } );
            } else {
                push @requestSoap, SOAP::Data->name( $key => \SOAP::Data->value(@listElements) );
            }
        } else {
            push @requestSoap, $self->_parseRequestField( $requestType, $key, $value );
        }
    }

    return @requestSoap;
}

sub _parseCustomList {
	my ($self,$listElement) = @_;

	my $element = {
		name=>"customField",
		attr=>{
			internalId=>$listElement->{internalId},
			'xsi:type'=>$listElement->{type},
		}
	};
	 if ( ref( $listElement->{value} ) eq 'HASH' ) {
         	$element->{value} = \SOAP::Data->name('value')->attr( $listElement->{value} );
         } else {
         	$element->{value} = \SOAP::Data->name('value')->value( $listElement->{value} );
         }
	 return SOAP::Data->new( %{$element} );
}
	

	

sub customField {
    my ( $self, %args ) = @_;

    my $element = {
        name  => "customField",
        attr  => { internalId => $args{internalId}, "xsi:type" => $args{type} },
        value => ( ref( $args{value} ) eq "HASH" ) ? \SOAP::Data->name('value')->attr( $args{value} ) : \SOAP::Data->name('value')->value( $args{value} ),
    };
    return SOAP::Data->new(%$element);
}

sub _parseRequestField {
    my $self  = shift;
    my $type  = shift;
    my $key   = shift;
    my $value = shift;

    if ( ref($value) eq "HASH" && defined $value->{soapData} ) {
        return $value->{soapData};
    }

    if ( ref($value) ne "HASH" ) { $value = { value => $value }; }

    undef my $element;
    if ( $self->{RECORD_FIELDS}->{$type}->{$key} eq 'core:RecordRef' ) {
        $element->{attr}->{internalId} = $value->{value};
    } else {
        $element->{value} = $value->{value};
    }
    $element->{name} = $key;
    $element->{attr}->{'xsi:type'} = $self->{RECORD_FIELDS}->{$type}->{$key};
    if ( $value->{type} ) { $element->{attr}->{type} = $value->{type}; }
    return SOAP::Data->new( %{$element} );

}

sub _logTransport {
    my $self   = shift;
    my $path   = shift;
    my $method = shift;

    my $dir = "$path/$method";
    if ( !-d $dir ) {
        mkdir $dir, 0777 or croak "Unable to create directory $dir";
    }

    my $fileName    = time;
    my $xmlRequest  = "$fileName-req.xml";
    my $xmlResponse = "$fileName-res.xml";

    undef my $flag;
    my $fh = File::Util->new();
    $flag = $fh->write_file(
        'file'    => "$dir/$xmlRequest",
        'content' => $self->{LAST_REQ},
        'bitmask' => 0644
    );

    if ( !$flag ) { croak "Unable to create file $dir/$xmlRequest" }

    $flag = $fh->write_file(
        'file'    => "$dir/$xmlResponse",
        'content' => $self->{LAST_RES},
        'bitmask' => 0644
    );

    if ( !$flag ) { croak "Unable to create file $dir/$xmlResponse" }

}

sub _parseResponse {
    my $self = shift;
    my $xml  = shift;

    # determine the method of the caller (login, get, search, etc)
    my ($method) = ( ( caller(1) )[3] =~ /^.*::(.*)$/ );

    $self->{LAST_REQ} = $self->{SOAP}->transport->http_request->content();
    $self->{LAST_RES} = $xml || $self->{SOAP}->transport->http_response->content();

    $self->_logTransport( $self->{LOGGINGDIR}, $method ) if $self->{LOGGINGDIR};

    my $p = new XML::Parser( Style => 'EasyTree' );
    my $tree = $p->parse( $self->{LAST_RES} );

    use vars qw($body $head);
    for my $header ( @{ $tree->[0]->{content} } ) {
        if    ( $header->{name} =~ /^.*:Header$/ ) { $head = $header; }
        elsif ( $header->{name} =~ /^.*:Body$/ )   { $body = $header; }
    }

    $self->{TIME}      = time;
    $self->{LAST_HEAD} = $head;
    $self->{LAST_BODY} = $body;

    if ( $method eq 'error' ) {

        # if the error is NOT being produced by the login function, the
        # structure is different, so the parsing must be different
        if ( ref $body->{content}->[0]->{content}->[0]->{content}->[0]->{content} eq 'ARRAY' ) {
            return _parseFamily( $body->{content}->[0]->{content}->[0]->{content}->[0]->{content} );
        } elsif ( $body->{content}->[0]->{content}->[2]->{content}->[0]->{content}->[0]->{name} =~ m/ns1:code/ ) {
            return _parseFamily( $body->{content}->[0]->{content}->[2]->{content}->[0]->{content} );
        } elsif ( $body->{content}->[0]->{content}->[2]->{content}->[0]->{name} eq 'ns1:hostname' ) {
            return _parseFamily( $body->{content}->[0]->{content} );
        }

        # WHY OH WHY, did they not allow for faults? Are you kidding me?
        elsif ( $body->{content}->[0]->{content}->[2]->{content}->[0]->{name} =~ /platformFaults:/ ) {
            return _parseFamily( $body->{content}->[0]->{content} );
        } else {
            croak 'Unable to parse error response!  Contact module author..';
        }
    } elsif ( ref $body->{content}->[0]->{content}->[0]->{content} eq 'ARRAY' ) {
        if ( $body->{content}->[0]->{name} eq "searchResponse" ) {
            return $self->_parseSearchResults( $body->{content}->[0]->{content}->[0]->{content} );
        }
        my $r = [];
        foreach ( @{ $body->{content}->[0]->{content}->[0]->{content} } ) {
            if ( $_->{name} =~ /readResponse|record|customizationRefList|baseRef|Response$/ ) {
                push( @$r, _parseFamily( [$_] ) );
            } elsif ($_->{name}=~/status$/) {
		push( @$r, $self->_parseStatus( $_ ) );
	    }
			
        }
        if ( scalar(@$r) > 1 ) { return $r; }
        return $r->[0];
    } else {
        return;
    }
}

sub _parseStatus {
	my ($self,$obj) =@_;


	my $ret = {statusIsSuccess=>$obj->{attrib}->{isSuccess},status=>{}};
	if (scalar(@{$obj->{content}})) {
		foreach my $code (@{$obj->{content}->[0]->{content}}) {
			$code->{name}=~s/^(\w+)\://;
			$ret->{status}->{$code->{name}} = $code->{content}->[0]->{content};
		}
	}
	return $ret;
			
		
}

sub _parseSearchResults {
    my ( $self, $tree ) = @_;

    my $res = {
        meta => {
            status => $tree->[0]->{attrib}->{isSuccess} eq "true",
            records => $tree->[1]->{content}->[0]->{content},
            perPage => $tree->[2]->{content}->[0]->{content},
            pages   => $tree->[3]->{content}->[0]->{content},
            index   => $tree->[4]->{content}->[0]->{content},
            id      => $tree->[5]->{content}->[0]->{content},
        },
        records => [],
    };
    foreach my $resr ( @{ $tree->[6]->{content} } ) {
        my $tr = _parseFamily( [$resr] );
        if ( $tr->{customFieldList} ) {
            $tr->{customFieldList} = $self->collapse_custom_fields($tr);
        }
        push( @{ $res->{records} }, $tr );
    }
    return $res;
    foreach my $result ( @{ $tree->[6]->{content} } ) {
        my $hash = $self->_attributes($result);
        foreach my $field ( @{ $result->{content} } ) {
            my $attr = $self->_attributes($field);
            my $key = substr( $field->{name}, index( $field->{name}, ":" ) + 1 );
            if ( $field->{name} =~ /listRel:customFieldList/ ) {
                foreach my $custom ( @{ $field->{content} } ) {
                    $hash->{ $custom->{attrib}->{internalId} } = $custom->{content}->[0]->{content}->[0]->{content};
                }
            } else {
                if ( $attr->{internalId} ) {
                    $hash->{$key} = $field->{content}->[0]->{content}->[0]->{content};
                    $hash->{ $key . "_id" } = $attr->{internalId};
                } else {
                    $hash->{$key} = $field->{content}->[0]->{content};
                }
            }
        }
        push( @{ $res->{records} }, $hash );
    }
    return $res;
}

sub _attributes {
    my ( $self, $obj ) = @_;

    my $hash = { map { substr( $_, index( $_, ":" ) + 1 ) => $obj->{attrib}->{$_} } keys %{ $obj->{attrib} } };
    return $hash;
}

sub _parseFault {
    my ( $self, $xml ) = @_;

    my $p = new XML::Parser( Style => 'EasyTree' );
    my $tree = $p->parse($xml);
    return $tree;
}

sub _parseFamily {
    my ( $array_ref, $store_ref ) = @_;

    undef my $parse_ref;
    for my $node ( @{$array_ref} ) {

        $node->{name} =~ s/^(.*:)?(.*)$/$2/g;
        if ( !defined $node->{content}->[0] ) {
            $parse_ref = &_parseNode( $node, $parse_ref );
        } else {
            if ( scalar @{ $node->{content} } == 1 ) {
                if ( ref $node->{content}->[0]->{content} eq 'ARRAY' ) {
                    if ( scalar @{ $node->{content}->[0]->{content} } > 1 ) {

                        #$parse_ref->{$node->{name}} = &_parseFamily($node->{content}->[0]->{content});
                        push @{ $parse_ref->{ $node->{name} } }, &_parseFamily( $node->{content} );
                    } else {

                        if ( $node->{name} =~ /List$/ ) {
                            if ( scalar @{ $node->{content}->[0]->{content} } > 1 ) {
                                for ( 0 .. scalar @{ $node->{content} } - 1 ) {
                                    push @{ $parse_ref->{ $node->{name} } }, &_parseFamily( $node->{content}->[$_]->{content} );
                                }
                            } else {
                                if ( !ref $node->{content}->[0]->{content}->[0]->{content} ) {
                                    $parse_ref = &_parseNode( $node->{content}->[0], $parse_ref, 1 );
                                } elsif ( !ref $node->{content}->[0]->{content}->[0]->{content}->[0]->{content} ) {
                                    $parse_ref = &_parseNode( $node->{content}->[0], $parse_ref, 1 );
                                } else {
                                    push @{ $parse_ref->{ $node->{name} } }, &_parseFamily( $node->{content}->[0]->{content} );
                                }
                            }
                        } else {
                            $parse_ref = &_parseNode( $node, $parse_ref );
                        }

                    }
                } else {
                    $parse_ref = &_parseNode( $node, $parse_ref );
                }
            } else {

                if ( $node->{name} =~ /(List|Matrix|itemJoin)$/ ) {
                    for ( 0 .. scalar @{ $node->{content} } - 1 ) {
                        if ( scalar @{ $node->{content}->[$_]->{content} } > 1 ) {
                            my $record = &_parseFamily( $node->{content}->[$_]->{content} );
                            $record = &_parseAttributes( $node->{content}->[$_], $record );
                            push @{ $parse_ref->{ $node->{name} } }, $record;
                        } else {
                            if ( !ref $node->{content}->[$_]->{content}->[0]->{content} ) {
                                $parse_ref = &_parseNode( $node->{content}->[$_], $parse_ref );
                            } else {
                                if ( !ref $node->{content}->[$_]->{content}->[0]->{content}->[0]->{content} ) {
                                    push @{ $parse_ref->{ $node->{name} } }, &_parseNode( $node->{content}->[$_] );
                                } elsif ( ref $node->{content}->[$_]->{content}->[0]->{content}->[0]->{content} ) {
                                    push @{ $parse_ref->{ $node->{name} } }, &_parseNode( $node->{content}->[$_]->{content}->[0] );
                                } else {
                                    push @{ $parse_ref->{ $node->{name} } }, &_parseNode( $node->{content}->[$_] );
                                }
                            }
                        }
                    }
                } else {
                    $parse_ref = &_parseFamily( $node->{content}, $parse_ref );
                }
            }
        }
        $parse_ref = &_parseAttributes( $node, $parse_ref );
    }

    #if ($store_ref) {
    #while (my ($key, $val) = each %{ $parse_ref }) {
    #$store_ref->{$key} = $val;
    #}
    #return $store_ref;
    #} else { return $parse_ref; }
    return $parse_ref;

}

sub _parseAttributes {
    my ( $hash_ref, $store_ref ) = @_;

    undef my $parse_ref;
    if ( defined $hash_ref->{name} ) {
        $hash_ref->{name} =~ s/^(.*:)?(.*)$/$2/g;
    }

    if ( defined $hash_ref->{attrib} ) {
        for my $attrib ( keys %{ $hash_ref->{attrib} } ) {
            next if $attrib =~ /^xmlns:/;
            if ( $attrib =~ /^xsi:type$/ ) {
                $hash_ref->{attrib}->{$attrib} =~ s/^(.*:)?(.*)$/lcfirst($2)/eg;
                $parse_ref->{ $hash_ref->{name} . 'Type' } = $hash_ref->{attrib}->{$attrib};
            } else {
                $parse_ref->{ $hash_ref->{name} . ucfirst($attrib) } = $hash_ref->{attrib}->{$attrib};
            }
        }
    }

    if ($store_ref) {
        while ( my ( $key, $val ) = each %{$parse_ref} ) {
            $store_ref->{$key} = $val;
        }
        return $store_ref;
    } else {
        return $parse_ref;
    }

}

sub _parseNode {
    my ( $hash_ref, $store_ref, $special ) = @_;

    undef my $parse_ref;
    if ( defined $hash_ref->{name} ) {
        $hash_ref->{name} =~ s/^(.*:)?(.*)$/$2/g;
    }

    if ( scalar @{ $hash_ref->{content} } == 1 && $special ) {
        my $key_name = $hash_ref->{attrib}->{internalId};
        if ( defined $hash_ref->{content}->[0]->{attrib}->{internalId} ) {
            $parse_ref->{$key_name} = $hash_ref->{content}->[0]->{attrib}->{internalId};
        } else {
            if ( ref( $hash_ref->{content}->[0]->{content} ) ) {
                $parse_ref->{$key_name} = $hash_ref->{content}->[0]->{content}->[0]->{content};
            } else {
                $parse_ref->{$key_name} = $hash_ref->{content}->[0]->{content};
            }
        }
    } else {
        if ( scalar @{ $hash_ref->{content} } == 1 ) {

            # if the name of the inner attribute is "name", then only worry about the value
            if ( defined $hash_ref->{content}->[0]->{name} ) {
                $hash_ref->{content}->[0]->{name} =~ /^(.*:)?(name|value)$/;
                if ( defined $hash_ref->{content}->[0]->{attrib}->{internalId} ) {
                    $parse_ref->{ $hash_ref->{name} . ucfirst($2) } = $hash_ref->{content}->[0]->{attrib}->{internalId};
                } else {
                    $parse_ref->{ $hash_ref->{name} . ucfirst($2) } = $hash_ref->{content}->[0]->{content}->[0]->{content};
                }
            } else {
                if ( defined $hash_ref->{content}->[0]->{content} ) {
                    if ( !ref $hash_ref->{content}->[0]->{content} ) {
                        $parse_ref->{ $hash_ref->{name} } = $hash_ref->{content}->[0]->{content};
                    }
                }
            }
        }

        # special case for MultiSelectCustomField
        elsif ( scalar @{ $hash_ref->{content} } > 1 && $hash_ref->{attrib}->{'xsi:type'} =~ /MultiSelect/i ) {
            my @internalIds;
            foreach my $oneval ( @{ $hash_ref->{content} } ) {
                if ( defined( $oneval->{attrib}->{internalId} ) ) {
                    push( @internalIds, $oneval->{attrib}->{internalId} );
                }
            }

            my $keyname = 'customField';
            $parse_ref->{$keyname} = join( ',', @internalIds );
        } else {
            $parse_ref = &_parseFamily( $hash_ref->{content} );
        }

        $parse_ref = &_parseAttributes( $hash_ref, $parse_ref );
    }

    if ( ref $store_ref eq 'HASH' ) {
        while ( my ( $key, $val ) = each %{$parse_ref} ) {
            $store_ref->{$key} = $val;
        }
        return $store_ref;
    } else {
        return $parse_ref;
    }

}

sub hasError { return $_[0]->{ERROR}; }

sub setError {
    my ( $self, $code, $message ) = @_;

    $self->{ERROR}         = 1;
    $self->{ERROR_RESULTS} = $message;
    $self->{ERROR_CODE}    = $code;
}

sub clearError {
    my $self = shift;

    $self->{ERROR}         = 0;
    $self->{ERROR_RESULTS} = "";
    $self->{ERROR_CODE}    = "";
}

sub error {
    my ( $self, $msg ) = @_;

    $self->setError( "INT", $msg );
}
sub errorCode { return $_[0]->{ERROR_CODE}; }
sub errorMsg  { return $_[0]->{ERROR_RESULTS}; }

sub handle_response {
    my ( $self, $xml ) = @_;

    $self->clearError();
    my $response = $self->{SOAP}->transport->http_response;
    if ( $response->code != 200 ) {
        if ( $response->status_line =~ /timeout/i ) {
            $self->setError( "TMO", sprintf( "Request timed out after %d seconds", $self->{SOAP}->transport->timeout ) );
        } elsif ( length($xml) ) {
            my $res  = $self->_parseFault($xml);
            my $node = $res->[0];
            while ( $node->{name} ne "soapenv:Fault" ) {
                $node = $node->{content}->[0];
            }
            $self->setError( "EXP", $node->{content}->[1]->{content}->[0]->{content} );
        } else {
            $self->setError( $response->code, $response->message );
        }
        return undef;
    }
    if ( !length($xml) ) {
        $self->setError( "NRS", "Server returned empty response" );
        return undef;
    }
    my $obj = $self->_parseResponse($xml);
    if ( ref($obj) eq "ARRAY" ) {
        if ( scalar(@$obj) == 1 ) {
            $obj = $obj->[0];
        } elsif ( defined $obj->[0]->{statusIsSuccess} ) {
            if ( $obj->[0]->{statusIsSuccess} eq 'true' ) {
                $obj = $obj->[1];
            } else {
                $obj = $obj->[0];
            }
        }
    }
    if ($@) {
        $self->setError( "PRS", sprintf( "Unable to parse response: %s", $@ ) );
        return undef;
    }
    if ( ref($obj) eq "ARRAY" ) {
        return $obj;
    }
    if ( $obj->{statusIsSuccess} eq "false" ) {
        $self->setError( $obj->{status}->{code}, $obj->{status}->{message} );
        return undef;
    }
    if ( $obj->{customFieldList} ) {
        $obj->{customFieldList} = $self->collapse_custom_fields($obj);
    }
    if ( $obj->{recordList} ) {
        my @tmp;
        foreach my $r ( @{ $obj->{recordList} } ) {
            if ( $r->{customFieldList} ) {
                $r->{customFieldList} = $self->collapse_custom_fields($r);
            }
            push( @tmp, $r );
        }
        $obj->{recordList} = [@tmp];
    }
    return $obj;
}

sub collapse_custom_fields {
    my ( $self, $obj ) = @_;

    return $obj if ( ref($obj) eq "ARRAY" );

    my $h = {};
    foreach my $cust ( @{ $obj->{customFieldList} } ) {
        $h->{ $cust->{customFieldInternalId} } = $cust->{customFieldValue};
    }
    delete $obj->{customFieldList};
    return $h;
}

1;

__END__

=head1 NAME

NetSuite - A perl-based interface to the NetSuite SuiteTalk (Web Services) API

=head1 SYNOPSIS

    use NetSuite;
    use Data::Dumper;
  
    my $ns = NetSuite->new({
        EMAIL => 'email@example.com',
        PASSWORD => 'cpan4life',
        ROLE => 3, # denotes and Administrator role
        ACCOUNT => 12345678, # NetSuite account number
    });
    
    $ns->login or die "Can't connect to NetSuite!";
    $ns->get('customer', 1234);
    print Dumper($ns->getResults);
    $ns->logout;

=head1 DESCRIPTION

NetSuite, Inc. is the leading provider of on-demand, integrated business
management software for growing and midsize businesses.  NetSuite's online
products and professional services, companies are enabled to manage all key
business operations — in a single hosted system, including: customer
relationship management (CRM); order fulfillment; inventory; accounting
and finance, product assembly; ecommerce; Web site management; and employee
productivity.

Along with this integrated suite, NetSuite offers direct access your company's
database through a very complex web services in SOAP (Simple Object Access
Protocol).  This module is designed to allow Perl developers a way to quickly,
easily, and efficiently communicate with this service.

Please note that although this module greatly improves communication with
NetSuite, it assumes you have a very good understanding of SOAP standards,
and are capable of reading an understanding the WSDL (Web Service
Definition Language) file for the service.

For more information on SOAP or WSDL, visit:

L<http://www.w3.org/TR/wsdl>
L<http://www.w3schools.com/wsdl/default.asp>
L<http://www.w3.org/TR/soap/>
L<http://www.w3schools.com/soap/default.asp>

=head1 PREFACE

Almost every method in this package requires a record type and internalId
number when working with new or existing records.  For a complete list
of acceptable record types, visit the coreTypes XSD file for web services
version 2.6.  Look for the "RecordType" simpleType.

L<https://webservices.netsuite.com/xsd/platform/v2_6_0/coreTypes.xsd>

Every record within NetSuite is assigned an internalId, in order to see
these hidden values, you must enable them within the NetSuite User Interface.
For instructions on enabling the display of internalId numbers, login
to your NetSuite account, selec the "Help" link on the top right-hand corner
and search for "Displaying Record and Field IDs".

=head1 USAGE

The following operations are currently supported: login logout add update
delete search searchMore searchNext get getSelectValue getCustomization

=head2 new

The constructor accepts the account information for your NetSuite account, and
some variables for debugging and error handling.  You can either set each
of the required values for login:

    use NetSuite;
    my $ns = NetSuite->new({
        EMAIL => 'email@example.com',
        PASSWORD => 'cpan4life',
        ROLE => 3, # denotes and Administrator role
        ACCOUNT => 12345678, # NetSuite account number
    });
    
Or you can edit the module and insert your account information as the
default values.  This will allow you to construct the object simply as:

    use NetSuite;
    my $ns = NetSuite->new({ DEFAULT => 1 });
    
If you are unsure of the role number to use, check the listing of roles
within the NetSuite UI by going to I<Setup > Users/Roles > Manage Roles>.

If you are unsure of your account number, go to I<Support > Customer Service
> Contact Support By Phone>.
    
There are also two additional parameters than can be declared during the
creation of a new object.

=head3 DEBUG

Setting the debug flag will require two additional modules in the
construction of the object: XML::Handler::YAWriter and XML::Parser::PerlSAX.

    use NetSuite;
    my $ns = NetSuite->new({ DEFAULT => 1, DEBUG => 1 });
    
This will cause the package to croak if an error occurs in the response from
NetSuite.  It will then process both the request and response, and pipe them
into STDOUT in a very well-formed display.  This will allow you to see
the constructed SOAP request and response, and compare it against what is
expected.  B<Make sure to turn this off in production code.>

=head3 ERRORDIR

If you are not interested in HALTING your application to check the request
and response, you can set an error directory to pipe the request and responses
from erroneous transactions.

These documents are stored in a file tree by operation.  So if you experience
errors from several operations the SOAP request are responses will be housed
in seperate directories.

The file names include a timestamp (in epoch), the operation performed, and
a suffix denoting the request or response.

    1201737600-add-req.xml
    1201737600-add-res.xml
    1201737601-get-req.xml
    1201737601-get-res.xml

B<Make sure this directory has write permissions.>

=head2 login

The login method attempts to login to NetSuite using the information passed
to the constructor.  If the login in successful, a true value (1) is returned,
otherwise it is undefined.  This allows you to call the login
method in a variety of ways.

    # One line connect statement w/ die
    $ns->login or die "Unable to login to NetSuite!";
    
    # Variable declaration and conditional
    my $loginStatus = $ns->login;
    if ($loginStatus) {
        # do something
    }
    
    # Method call as conditional
    if ($ns->login) {
        # do something
    }
    
If the login is successful, the results will be passed to the loginResults
method, otherwise call the errorResults method.

=head2 loginResults

The loginResults method returns the results of a successful login request.
It is a hash reference that contains the role list and internalId of the user
being logged in.

    {
        'wsRoleList' => [
                      {
              'isInactive' => 'false',
              'isDefault' => 'false',
              'roleInternalId' => '1014',
              'roleName' => 'Web Services Only'
                      }
                    ],
        'userId' => '965',
        'statusIsSuccess' => 'true'
    }
    
B<If the login attempt was unsuccessful, the error details are sent to the
errorResults method.>

=head2 logout

The logout method attempts to end the current session with NetSuite.  If the
operation is successful, a true value (1) is returned, otherwise it is
undefined.

B<This method is trival because a new login request will trump any previous
session.>

=head2 logoutResults

The loginResults method returns the results of a successful logout request.
It is a useless hash reference for a trival method call.  But here you go!

    {
        'statusIsSuccess' => 'true'
    }

=head2 add(recordType, hashReference)

The add method submits a new record to NetSuite.  It requires a record type,
and hash reference containing the data of the record.

For a boolean value, the request uses a numeric zero to represent false, and
the textual word "true" to represent true.  I believe this is an error with
NetSuite; identified in their last release.

For a record reference field, like entityStatus, simply pass the numeric
internalId of the field.  If you are unsure what the internalIds are for
a value, check the getSelectValue method.

For an enumerated value, simply submit a string.

For a list value, pass an array of hashes.

    my $customer = {
        isPerson => 0, # meaning false
        companyName => 'Wolfe Electronics',
        entityStatus => 13, # notice I only pass in the internalId
        emailPreference => '_hTML', # enumerated value
        unsubscribe => 0,
        addressbookList => [
          {
              defaultShipping => 'true',
              defaultBilling => 0,
              isResidential => 0,
              phone => '650-627-1000',
              label => 'United States Office',
              addr1 => '2955 Campus Drive',
              addr2 => 'Suite 100',
              city => 'San Mateo',
              state => 'CA',
              zip => '94403',
              country => '_unitedStates',
          },
        ],
    };

    my $internalId = $ns->add('customer', $customer);
    print "I have added a customer with internalId $internalId\n";

If successful this method will return the internalId of the newly generated
record.  Otherwise, the error details are sent to the errorResults method.

If you wanted to ensure a record was submitted successfully, I recommend
the following syntax:

    if (my $internalId = $ns->add('customer', $customer)) {
        print "I have added a customer with internalId $internalId\n";
    }
    else {
        print "I failed to add the customer!\n";
    }

=head2 update(recordType, hashReference)

The update method will request an update of an existing record.  The only
difference with this operation is that the internalId of the record being
updated must be present inside the hash reference.

    my $customer = {
        internalId => 1234, # the internaldId of the record being updated
        phone => '555-555-5555',
    };

    my $internalId = $ns->update('customer', $customer);
    print "I have updated a customer with internalId $internalId\n";
    
If successful this method will return the internalId of the updated record
Otherwise, the error details are sent to the errorResults method.

=head2 delete(recordType, internalId)

The delete method very simply deletes a record.  It requires the record type
and internalId number for the record.

    my $internalId = $ns->delete('customer', 1234);
    print "I have deleted a customer with internalId $internalId\n";

If successful this method will return the internalId of the deleted record
Otherwise, the error details are sent to the errorResults method.

=head2 search(searchType, hashReference, configReference)

The search method submits a query to NetSuite.  If the
query is successful, a true value (1) is returned, otherwise it is
undefined.

To conduct a very basic search for all customers, excluding inactive accounts,
I would write:

    my $query = {
        basic => [
            { name => 'isInactive', value => 0 } # 0 means false
        ]
    };
    
    $ns->search('customer', $query);
    
Notice that the query is a hash reference of search types.  Foreach search type
in the hash there is an array of hashes for each field in the criteria.

Once the query is constructed, I designate the search to use and the query.
And submit it to NetSuite.

This query structure may seem confusing, especially in a simply example.  But
within NetSuite there are several different searches you can perform.
Some examples of these searchs are:

customer
contact
supportCase
employee
calendarEvent
item
opportunity
phoneCall
task
transaction

Then within each search, you can also B<join> with other searches to combine
information.  To demonstrate a more complex search, we will take this example.

Let's imagine you wanted to see transactions, specifically sales orders,
invoices, and cash sales, that have transpired over the last year.

    my $query = {
        basic => [
            { name => 'mainline', value => 'true' },
            { name => 'type', attr => { operator => 'anyOf' }, value => [
                    { value => '_salesOrder' },
                    { value => '_invoice' },
                    { value => '_cashSale' },
                ]   
            },
            { name => 'tranDate', value => 'previousOneYear', attr => { operator => 'onOrAfter' } },
        ],
    };
    
From that list, you want to see if the customer associated with each transaction
has a valid email address on file, and is not a lead or a prospect.  The
joined query would look like this:

    my $query = {
        basic => [
            { name => 'mainline', value => 'true' },
            { name => 'type', attr => { operator => 'anyOf' }, value => [
                    { value => '_salesOrder' },
                    { value => '_invoice' },
                    { value => '_cashSale' },
                ]   
            },
            { name => 'tranDate', value => 'previousOneYear', attr => { operator => 'onOrAfter' } },
        ],
        customerJoin => [
            { name => 'email', attr => { operator => 'notEmpty' } },
            { name => 'entityStatus', attr => { operator => 'anyOf' }, value => [
                    { attr => { internalId => '13' } },
                    { attr => { internalId => '15' } },
                    { attr => { internalId => '16' } },
                ]                                  
            },
        ],
    };
    
Notice that each hash reference within either the basic or customerJoin
arrays has a "name" and "value" key.  In some cases you also have an
"attr" key.  This "attr" key is another hash reference that contains
the operator for a field, or the internalId for a field.

Also notice that for enumerated search fields, like "entityStatus" or "type",
the "value" key contains an array of hashes.  Each of these hashes represent
one of many possible collections.

To take this a step further, we may want to search for some custom fields
that exists in a customer's record.  These custom fields are located in the
"customFieldList" field of a record and can be queries like so:

    my $query = {
        basic => [
            { name => 'customFieldList', value => [
                    {
                        name => 'customField',
                        attr => {
                            internalId => 'custentity1',
                            operator => 'anyOf',
                            'xsi:type' => 'core:SearchMultiSelectCustomField'
                        },
                        value => [
                            { attr => { internalId => 1 } },
                            { attr => { internalId => 2 } },
                            { attr => { internalId => 3 } },
                            { attr => { internalId => 4 } },
                        ]
                    },
                ],
            },
        ],
    };
    
Notice that we have added a new layer to the "attr" key called 'xsi:type'.
That is because this module cannot determine the custom field types for YOUR
particular NetSuite account in real time.  Thus, you have to provide them
within the query.

If the search is successful, a true value (1) is returned, otherwise it is
undefined.  If successful, the results are passed to the searchResults method,
otherwise call the errorResults method.

Also, for this method, you are given special access to the header of the
search request.  This allows you to designate the number of records to be
returned in each set, as well as whether to return just basic information
about the results, or extended information about the results.

    # perform a search and only return 10 records per page
    $ns->search('customer', $query, { pageSize => 10 });
    
    # perform a search and only provide basic information about the results
    $ns->search('customer', $query, { bodyFieldsOnly => 0 });

=head2 searchResults

The searchResults method returns the results of a successful search request.
It is a hash reference that contains the record list and details of the search.

    {
        'recordList' => [
            {
                'accessRoleName' => 'Customer Center',
                'priceLevelInternalId' => '3',
                'unbilledOrders' => '2512.7',
                'entityStatusName' => 'CUSTOMER-Closed Won',
                'taxItemInternalId' => '-112',
                'lastPageVisited' => 'login-register',
                'isInactive' => 'false',
                'shippingItemName' => 'UPS Ground',
                'entityId' => 'A Wolfe',
                'entityStatusInternalId' => '13',
                'accessRoleInternalId' => '14',
                'recordExternalId' => 'entity-5',
                'webLead' => 'No',
                'territoryName' => 'Default Round-Robin',
                'recordType' => 'customer',
                'emailPreference' => '_default',
                'taxItemName' => 'CA-SAN MATEO',
                'taxable' => 'true',
                'partnerName' => 'E Auctions Online',
                'companyName' => 'Wolfe Electronics',
                'shippingItemInternalId' => '92',
                'leadSourceName' => 'Accessory Sale',
                'creditHoldOverride' => '_auto',
                'title' => 'Perl Developer',
                'priceLevelName' => 'Employee Price',
                'partnerInternalId' => '170',
                'giveAccess' => 'true',
                'visits' => '150',
                'stage' => '_customer',
                'termsName' => 'Due on receipt',
                'defaultAddress' => 'A Wolfe<br>2955 Campus Drive<br>Suite 100
<br>San Mateo CA 94403<br>United States',
                'lastVisit' => '2008-03-22T16:40:00.000-07:00',
                'isPerson' => 'false',
                'recordInternalId' => '-5',
                'fax' => '650-627-1001',
                'salesRepInternalId' => '23',
                'dateCreated' => '2006-07-22T00:00:00.000-07:00',
                'termsInternalId' => '4',
                'salesRepName' => 'Clark Koozer',
                'unsubscribe' => 'false',
                'categoryInternalId' => '2',
                'phone' => '650-555-9788',
                'shipComplete' => 'false',
                'lastModifiedDate' => '2008-01-28T19:28:00.000-08:00',
                'territoryInternalId' => '-5',
                'categoryName' => 'Individual',
                'firstVisit' => '2007-03-24T16:13:00.000-07:00',
                'leadSourceInternalId' => '100102'
            },
        ],
        'totalPages' => '79', # the total number of pages in the set
        'totalRecords' => '790', # the total records returned by the search
        'pageSize' => '10', # the number of records per page
        'pageIndex' => '1', # the current page
        'statusIsSuccess' => 'true'
    }
    
The "recordList" field is an array of hashes containing a record's values.
Refer to the get method for details on the understanding of a record's data
structure.

=head2 searchMore(pageIndex)

If your initial search returns several pages of results, you can jump
to another result page quickly using the searchMore method.

For example, if after performing an initial search you are given 1 of 100
records, when there are 500 total records.  You could quickly jump to the
301-400 block of records by entering the pageIndex value.

    $ns->search('customer', $query);
    
    # determine my result set
    my $totalPages = $ns->searchResults->{totalPages};
    my $pageIndex = $ns->searchResults->{pageIndex};
    my $totalRecords = $ns->searchResults->{totalRecords};
    
    # output a message
    print "I found $totalRecords records!\n";
    print "Displaying page $pageIndex of $totalPages\n";
    
    my $jumpToPage = 3;
    $ns->searchMore($jumpToPage);
    print "Jumping to page $jumpToPage\n";
    print "Now displaying page $jumpToPage of $totalPages\n";

=head2 searchNext

If your initial search returns several pages of results, you can automatically
jump to the next page of results using the searchNext function.  This is
most useful when downloading sets of more than 1000 records.  (Which is the
limit of an initial search).

    $ns->search('transaction', $query);
    if ($ns->searchResults->{totalPages} > 1) {
        while ($ns->searchResults->{pageIndex} != $ns->searchResults->{totalPages}) {
            for my $record (@{ $ns->searchResults->{recordList} }) {
                my $internalId = $record->{recordInternalId};
                print "Found record with internalId $internalId\n";
            }
            $ns->searchNext;
        }
    }

=head2 get(recordType, internalId)

The get method returns the most complete information for a record.

    # to see an individual field in the response
    if ($ns->get('customer', 1234)) {
        my $firstName = $ns->getResults->{firstName};
        print "I got a customer with the first name $firstName\n";
    }
    
    # to output the complete data structure
    my $getSuccess = $ns->get('customer', 1234);
    if ($getSuccess) {
        print Dumper($ns->getResults);
    }
    
If the operation in successful, a true value (1) is returned,
otherwise it is undefined.

The results will be passed to the getResults method, otherwise
call the errorResults method.

=head2 getResults

The getResults method returns a hash reference containing all of the
information for a given record.  (Some fields were omitted)

    {
        'recordInternalId' => '1234',
        'recordExternalId' => 'entity-5',
        'recordType' => 'customer',
        'isInactive' => 'false',
        'entityStatusInternalId' => '13',
        'entityStatusName' => 'CUSTOMER-Closed Won',
        'entityId' => 'A Wolfe',
        'emailPreference' => '_default',
        'fax' => '650-627-1001',
        'contactList' => [
            {
                'contactInternalId' => '25',
                'contactName' => 'Amy Nguyen'
            },
        ],
        'creditCardsList' => [
            {
                'ccDefault' => 'true',
                'ccMemo' => 'This is the preferred credit card.',
                'paymentMethodName' => 'Visa',
                'paymentMethodInternalId' => '5',
                'ccNumber' => '************1111',
                'ccExpireDate' => '2010-01-01T00:00:00.000-08:00',
                'ccName' => 'A Wolfe'
            }
        ],
        'addressbookList' => [
            {
                'country' => '_unitedStates',
                'defaultShipping' => 'true',
                'internalId' => '244715',
                'defaultBilling' => 'true',
                'phone' => '650-627-1000',
                'state' => 'CA',
                'addrText' => 'A Wolfe<br>2955 Campus Drive<br>Suite 100<br>San Mateo CA 94403<br>United States',
                'addr2' => 'Suite 100',
                'zip' => '94403',
                'city' => 'San Mateo',
                'isResidential' => 'false',
                'addressee' => 'A Wolfe',
                'addr1' => '2955 Campus Drive',
                'override' => 'false',
                'label' => 'Default'
            }
        ],
        'dateCreated' => '2006-07-22T00:00:00.000-07:00',
        'lastModifiedDate' => '2008-01-28T19:28:00.000-08:00',
    };
    
It is important to note how some of this data is returned.

Notice that the internalId for the record is labeled "recordInternalId"
instead of just "internalId".  This is the same for the "recordExternalId".

For a boolean value, the response the string "true" or "false.

For a record reference field, like entityStatus, the name of this value
and its internalId are returned as two seperate values: entityStatusName
and entityStatusInternalId.  This appending of the words "Name" and "InternalId"
after the field name is the same for all reference fields.

For an enumerated value, a string is returned.

For a list, the value is an array of hashes.  Even if the list contains only
a single hash reference, it will still be returned as an array.

The easiest way to access an understand this function, is to dump the response
and determine the best way to interate through your data.  For example,
if I wanted to see if the customer had a default credit card selected, I might
write:

    if ($ns->get('customer', 1234)) {
        if (defined $ns->getResults->{creditCardsList}) {
            if (scalar @{ $ns->getResults->{creditCardsList} } == 1) {
                print "This customer has a default credit card!\n";
            }
            else { 
                for my $creditCard (@{ $ns->getResults->{creditCardsList} }) {
                    if ($creditCard->{ccDefault} eq 'true') {
                        print "This customer has a default credit card!\n";
                    }
                }
            }
        }
        else {
            "There are no credit cards on file!\n";
        }
    }
    else {
        # my get request failed, better check the errorResults method
    }
    
Or, if I was more concerned with checking this customers last activity, I
might write:

    $ns->get('customer', 1234);
    
    # assuming the request was successful
    my $internalId = $ns->getResults->{recordInternalId};
    my $lastModifiedDate = $ns->getResults->{lastModifiedDate};
    print "Customer $internalId was last updated on $lastModifiedDate.\n";

=head2 getSelectValue

The getSelectValue method returns a list of internalId numbers and names for
a record reference field.  For instance, if you wanted to know all of the
acceptable values for the "terms" field of a customer you could submit
a request like:

    $ns->getSelectValue('customer_terms');
    
If successful, a call to the getResults method, will return a hash reference
that looks like this:

    {
        'recordRefList' => [
          {
              'recordRefInternalId' => '5',
              'recordRefName' => '1% 10 Net 30'
          },
          {
              'recordRefInternalId' => '6',
              'recordRefName' => '2% 10 Net 30'
          },
          {
              'recordRefInternalId' => '4',
              'recordRefName' => 'Due on receipt'
          },
          {
              'recordRefInternalId' => '1',
              'recordRefName' => 'Net 15'
          },
          {
              'recordRefInternalId' => '2',
              'recordRefName' => 'Net 30'
          },
          {
              'recordRefInternalId' => '3',
              'recordRefName' => 'Net 60'
          }
        ],
        'totalRecords' => '6',
        'statusIsSuccess' => 'true'
    }
    
If the request fails, the error details are sent to the errorResults method.

From these results, we now know that the "terms" field of a customer can be
submitted using any of the recordRefInternalIds.  Thus, to update a customer's
terms, we might write:

    my $customer = {
        internalId => 1234,
        terms => 4, # Due on receipt
    }

    $ns->update('customer', $customer);

For a complete list of acceptable values for this operation, visit the
coreTypes XSD file for web services version 2.6.
Look for the "GetSelectValueType" simpleType.

L<https://webservices.netsuite.com/xsd/platform/v2_6_0/coreTypes.xsd>

=head2 getCustomization

The getCustomization retrieves the metadata for Custom Fields, Lists, and
Record Types.  For instance, if you wanted to know all of the
custom fields for the body of a transaction, you might write:

    $ns->getCustomization('transactionBodyCustomField');
    
If successful, a call to the getResults method, will return a hash reference
that looks like this:

    {
        'recordList' => [
          {
              'fieldType' => '_phoneNumber',
              'sourceFromName' => 'Phone',
              'bodyPrintStatement' => 'false',
              'bodyAssemblyBuild' => 'false',
              'bodySale' => 'true',
              'bodyItemReceiptOrder' => 'false',
              'isMandatory' => 'false',
              'recordType' => 'transactionBodyCustomField',
              'bodyPurchase' => 'false',
              'bodyPickingTicket' => 'true',
              'bodyExpenseReport' => 'false',
              'name' => 'Entity',
              'bodyItemFulfillmentOrder' => 'false',
              'bodyPrintPackingSlip' => 'false',
              'isFormula' => 'false',
              'sourceFromInternalId' => 'STDENTITYPHONE',
              'bodyItemFulfillment' => 'false',
              'label' => 'Customer Phone',
              'bodyJournal' => 'false',
              'showInList' => 'false',
              'recordInternalId' => 'CUSTBODY1',
              'help' => 'This is the customer\'s phone number from the
customer record.  It is generated dynamically every time the form is accessed
 - so that changes in the customer record will be reflected the next time the
 transaction is viewed/edited/printed.<br>Note: This is an example of a
 transaction body field, sourced from a customer standard field.',
              'storeValue' => 'false',
              'isParent' => 'false',
              'defaultChecked' => 'false',
              'bodyInventoryAdjustment' => 'false',
              'bodyOpportunity' => 'false',
              'bodyPrintFlag' => 'true',
              'checkSpelling' => 'false',
              'displayType' => '_disabled',
              'bodyItemReceipt' => 'false',
              'sourceListInternalId' => 'STDBODYENTITY',
              'bodyStore' => 'false'
          },
          'totalRecords' => '1',
          'statusIsSuccess' => 'true'
    };

If the request fails, the error details are sent to the errorResults method.

For a complete list of acceptable values for this operation, visit the
coreTypes XSD file for web services version 2.6.
Look for the "RecordType" simpleType.

L<https://webservices.netsuite.com/xsd/platform/v2_6_0/coreTypes.xsd>

=head2 errorResults

The errorResults method is populated when a request returns an erroneous
response from NetSuite.  These errors can occur at anytime and with any
operation.  B<Always assume your operations will fail, and build your
code accordingly.>

The hash reference that is returned looks like this:

    {
        'message' => 'You have entered an invalid email address or account
number. Please try again.',
        'code' => 'INVALID_LOGIN_CREDENTIALS'
    };

If there is something FUNDAMENTALLY wrong with your request
(like you have included an invalid field), your errorResults
may look like this:

    {
        'faultcode' => 'soapenv:Server.userException',
        'detailDetail' => 'partners-java002.svale.netledger.com',
        'faultstring' => 'com.netledger.common.schemabean.NLSchemaBeanException:
<<somefield>> not found on {urn:relationships_2_6.lists.webservices.netsuite.com}Customer'
    };
    
Thus, a typical error-prepared script might look like this:

    $ns->login or die "Can't connect to NetSuite!\n";
    
    if ($ns->search('customer', $query)) {
        for my $record (@{ $ns->searchResults->{recordList} }) {
            if ($ns->get('customer', $record->{recordInternalId})) {
                print Dumper($ns->getResults);
            }
            else {
                # If an error is encountered while running through
                # a list, print a notice and break the loop
                print "An error occured!\n";
                last;
            }
        }
    }
    else {
        
        # I really want to know why my search would fail
        # lets output the error and message
        my $message = $ns->errorResults->{message};
        my $code = $ns->errorResults->{code};
        
        print "Unable to perform search!\n";
        print "($code): $message\n";
        
    }
    
    $ns->logout; # no error handling here, if this fails, oh well.

For a complete listing of errors and associated messages, consult the
SuiteTalk (Web Services) Records Guide.

L<http://www.netsuite.com/portal/developers/resources/suitetalk-documentation.shtml>

=head1 DEBUGGING

=head2 getRequest

Returns a string of the last request made to NetSuite.  It is raw XML,
including the standard header, and can be directly stored to a file for logging.

=head2 getResponse

Returns a string of the last response returned from NetSuite.  It is raw XML,
including the standard header, and can be directly stored to a file for logging.

=head2 getHead

Returns a complex data structure representing the header of a NetSuite SOAP
response, after it has been run through the XML::Parser. You shouldn't need
this method unless you are debugging the internal parsers of this package.
That's my job.

=head2 getBody

Returns a complex data structure representing the body of a NetSuite SOAP
response, after it has been run through the XML::Parser. You shouldn't need
this method unless you are debugging the internal parsers of this package.
That's my job.

=head1 TODO

There are several operations that are available through the web service that
I have not yet implemented.  At Catalina Lifesciences, we have never had a
need for these components yet, but I have no problem implementing them if
there is a demand.  Please don't hesitate to send me an e-mail.

addList
updateList
deleteList
getList
getAll
getItemAvailability
attach / detach
changePasswordOrEmail
getDeleted
initialize / initializeList

I also haven't delved into Asynchronous Request Processing, which would
allow you to submit multiple requests to NetSuite, check the status of
each request, and then once completed, receive the result(s).  The methods
to support these type of calls include:

asyncAddList
asyncUpdateList
asyncDeleteList
asyncGetList
asyncSearch
asyncInitializeList

Again, if anyone finds themselves interested in these methods, let me know
and I can work toward implementing them.  I currently have no plan to.

=head1 AUTHOR

Jonathan Lloyd, L<mailto:webmaster@lifegames.org>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Jonathan Lloyd. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 ACKNOWLEDGEMENTS

The development and release of the NetSuite modules was made possible by
Catalina Lifesciences, Inc. (L<http://www.catalinalifesciences.com>).

This module has been released after notifying NetSuite, Inc., and has a test
suite that is supported by a SuiteFlex Developer Account.

A special thanks to our NetSuite Account Manager, A.J. Gard.

=cut
