package Fap::Model::DBIx;

use strict;
use Data::Dumper qw(Dumper);
use Fap::Model::Cache();
use Fap;
use Try::Tiny qw(try catch);
use Fap::Model::DBIx::Auth();
use Fap::Model::DBIx::ResultSet();
use Fap::Model::DBIx::Cache;
use File::Slurp;

use constant default_expires => 60;
$SIG{__WARN__} = sub { foreach (@_) {  print STDERR "$_\n" if ($_!~/Prefetch/);} };

###########################################################################
# new : initialize DBIx wrapper
# must be subclassed by Fap::Model::DBIx::<SchemaName>
#
# Example: my $db = Fap::Model::DBIx::Pbxtra->new(dsn=>"dbi:mysql:dbname",user=>"dbuser",pass=>"dbpass");
#
# 	Args:
#       server: server group from <fcs_root>/conf/database.conf
#	mode: (sandbox|production|undef) force sandbox or production db server selection in Fap::Model::DBIx::Auth. undef autodetects
# 	debug: activate DBIx::Class debug statements
# 	noncache: disable caching layer
#
###########################################################################
$ENV{DBIC_DONT_VALIDATE_RELS} = 1;

sub new {
    my ( $class, %args ) = @_;

    if ( __PACKAGE__ eq $class ) {
        die __PACKAGE__ . " is an abstract class.\n";
    }
    my $self = bless {
        schema => undef,
        cache  => undef,
        host   => $args{host},
	test_mode=>$args{test_mode},
	use_dbn=>$args{use_dbn},
    }, $class;

	#print STDERR "\n$class: $ENV{REQUEST_URI} = $ENV{REQCHECK}\n";

    my $auth = Fap::Model::DBIx::Auth->new( server =>$self->server_group||$args{server}, mode => $args{mode},switch=>$args{switch} );
    my $ex = {};


    if ( !$args{nocache} ) {
        $ex->{cursor_class} = "Fap::Model::DBIx::Cache";
        $self->{cache} = Fap::Model::Cache->memory;# Cache::Memcached->new( { servers => $auth->cache_servers, compress_threshold => 5000 } );
	#$self->{cache} = Cache::Memcached->new( { servers => $auth->cache_servers, compress_threshold => 5000 } );
    }

    $self->{schema} = $self->schema_class->connect( $auth->dsn( $self->dbn ), $auth->user, $auth->pass, $ex );
    if ( $args{debug} ) {
        $self->schema->storage->debug(1);
    }
    if ( !$args{nocache} ) {
        #$self->schema->default_resultset_attributes( { cache_object => $self->cache } );
    }
    $self->{schema}->storage->dbh->do("set sql_safe_updates=1;");

    return $self;
}



###########################################################################
# table: shorthand for $db->{schema}->resultset(<table>)
#
#	Example: my $res = $db->table("items")->search(...);
#
#	Args:
#	table name (in dbix style or as-is in database)
#       args hash:
#		inflated: undef/1 return rows as DBIx::Class::ResultClass::HashRefInflator
#	Returns:  DBIx resultset
##########################################################################

sub table {
    my ( $self, $table, %args ) = @_;


    if ( $table !~ /^[A-Z]/ ) {
        $table = $self->_dbix_normalize($table);
    }
    if ($self->foreign_table($table)) {
	$table=$self->foreign_table($table);
    }
    my $res = bless $self->schema->resultset($table), "Fap::Model::DBIx::ResultSet";
    $res->{cache} = $self->{cache};
    return $res;
}
sub get_cloned_table {
	my ($self,$table,%args) = @_;

	my $res = $self->table($table,%args);
	my $current_name = $res->result_source->{name};	
	my $new_name;
	if ($args{prefix}) {
		$new_name = $args{prefix}."_$current_name" if ($res->result_source->{name}!~/^$args{prefix}/);
	} else {
		$new_name =$current_name."_$args{suffix}" if ($res->result_source->{name}!~/$args{suffix}$/);
	}
	$res->result_source->{name} = $new_name;
	return $res;
}
sub clone_table {
	my ($self,$tablename,%args) = @_;

	my $tablename = $self->_dbix_normalize($tablename);
	my $table = $self->table($tablename);
	my $current_name = $table->result_source->{name};
	
	my $new_name;

        if ($args{prefix}) {
                $new_name = $args{prefix}."_$current_name";
        } else {
                $new_name =$current_name."_$args{suffix}";
        }
	$self->schema->{source_registrations}->{$tablename}->{name} = $new_name;
	$table->result_source->{name} = $new_name;
	my $count=undef;
	try {
		$count = $table->count();
        } catch {
	};
	return $table if (defined $count);
	my $package_name = $self->_dbix_normalize($new_name);
	my $path = Fap->path_to("lib",join("/",(split(/::/,$table->result_class)))).".pm";
	my $current_text = File::Slurp::read_file($path);
	$current_text=~s/table\("$current_name"\)/table("$new_name")/;
	File::Slurp::write_file("/dev/shm/$tablename.pm",$current_text);
	$self->schema->deploy({sources=>[$tablename],validate=>1},"/dev/shm");
	try {
                $count = $table->count();
        } catch {
		return undef;
        };

	unlink("/dev/shm/$tablename.pm");
	return $table;
}
	
sub foreign_table {
	return undef;
}

sub options {
	my ($self, $table) = @_;
	 if ( $table !~ /^[A-Z]/ ) {
      		$table = $self->_dbix_normalize($table);
	}
	my $classname = "Fap::Model::Fcs::Ref::$table";
	if ($classname->can("options") ) {
		return $classname->options;
	}
	return {};
}



###########################################################################
# strip: strip out column data from DBIx::Class objects
#
#	Example: my $just_hashes = [$db->strip($db->table("example_table")->all)];
#
#	Args:
#	At least one DBIx::Class object
#	Returns:
#	At least one hashref containing column data for that object
###########################################################################

sub strip {
    my ( $self, @records ) = @_;
    my @ret;
    foreach my $rec (@records) {
        if ($rec) {
            push( @ret, $rec->strip );
        }
    }
    if (wantarray) {
        return @ret;
    } else {
        if ( scalar(@ret) > 1 ) {
            return [@ret];
        } else {
            return $ret[0];
        }
    }
}

sub uniques {
    my ( $self, @records ) = @_;
    my @ret;
    foreach my $rec (@records) {
        if ($rec) {
            push( @ret, $rec->unique );
        }
    }
    if (wantarray) {
        return @ret;
    } else {
        if ( scalar(@ret) > 1 ) {
            return [@ret];
        } else {
            return $ret[0];
        }
    }
}

###########################################################################
# json : strip records qand serialize to JSON
#
#	Example: my $json = $db->serialize($db->strip($db->table("example_table")->all));
#
#	Args:
#       At least one DBIx::Class object
#       Returns:
#       JSON string
###########################################################################

sub json {
    my ( $self, @records ) = @_;

    return encode_json( [ $self->strip(@records) ] );
}

###########################################################################
# caching functions
#
# Sometimes it may be necessary to access the caching layer directly and not through DBIx::Class::Cursor::Cached
#
# All functions accept as a parameter a key, which can be plaintext or a hash reference which will be normalized into a key
#
###########################################################################
sub cache_set {
    my ( $self, %args ) = @_;

    return if !$self->cache;
    $self->cache->set( $self->_handle_key( $args{key} ), $args{record}, $args{expires} || $self->default_expires );
}

sub cache_get {
    my ( $self, $key ) = @_;

    return if !$self->cache;
    return $self->cache->get( $self->_handle_key($key) );
}

sub cache_remove {
    my ( $self, $key ) = @_;

    return if !$self->cache;
    $self->cache->delete( $self->_handle_key($key) );
}


###########################################################################
# dbix_normalize: format a table name into DBIx::Class format
#
# called internally from table()
##########################################################################
sub _dbix_normalize {
    my ( $self, $table ) = @_;

    $table = ucfirst( lc($table) );
    $table =~ s/_([a-z0-9])/uc($1)/eg;
    $table =~ s/[sS]$//;
    return $table;
}

sub transaction {
    my $self = shift;

    $self->schema->txn_begin;
}

sub commit {
    my $self = shift;

    $self->schema->txn_commit;
}

sub rollback {
    my $self = shift;

    $self->schema->txn_rollback;
}

sub set_server_id {
}

###########################################################################
# _handle_key: map a hashref into a cache key
###########################################################################

sub _handle_key {
    my ( $self, $key ) = @_;

    return $key if ( ref($key) ne "HASH" );
    return join( "|", map { "$_:$key->{$_}" } sort keys %$key );
}
sub cache  { return $_[0]->{cache}; }
sub schema { return $_[0]->{schema}; }
sub host   { return $_[0]->{host} || "localhost"; }

sub dbh {
	my ($self,$which) = @_;

	my $dbh =$self->schema->storage->dbh;
	if ($which) {
		# use fcstest if test_mode or FCS_TEST is on and trying to switch to fcs db
		if ( ($ENV{FCS_TEST} == 1 || $self->{test_mode}) && $which eq 'fcs' ) {
			$which = 'fcstest';
		}
		$dbh->do("use $which;");
	}
    	return $dbh;
}
sub switch_db {
	my ($self,$which) = @_;

	# use fcstest if test_mode or FCS_TEST is on and trying to switch to fcs db
	if ( ($ENV{FCS_TEST} == 1 || $self->{test_mode}) && $which eq 'fcs' ) {
		$which = 'fcstest';
	}
	$self->schema->storage->dbh->do("use $which");
}

sub DESTROY {
    my $self = shift;

    try {
        $self->schema->storage->dbh->disconnect;
    }
    catch {

    };
}
sub server_group { return undef; }

1;
__DATA__
