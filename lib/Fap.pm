package Fap;
use strict;
use Cwd;
use Fap::ConfLoader;
use Sys::Hostname();

# sub path_to: return full path to FCS Root directory

sub path_to {
    my ( $class, @dirs ) = @_;

    if ( !$ENV{FON_DIR} || !-e $ENV{FON_DIR} ) {
        my $dir;
        if ( index( __FILE__, "Fap" ) > 0 ) {
            my @path = split( /\//, substr( __FILE__, 0, index( __FILE__, "Fap" ) - 1 ) );
            pop(@path);
            $dir = "/" . join( "/", @path );
        } else {
            $dir = substr( getcwd, 0, rindex( getcwd(), "/" ) );
        }
        if ( !-e $dir && -e substr( $dir, 1 ) ) { $dir = substr( $dir, 1 ); }
        $dir = substr( $dir, 1 ) if ( $dir =~ /^\/\// );
        $ENV{FON_DIR} = $dir;
    }
    return join( "/", $ENV{FON_DIR}, @dirs );
}

sub rmkdir {
        my ($dir,$from_file) = @_;

	if ($from_file) {
		$dir = substr($dir,0,rindex($dir,"/"));
	}
        return if (-d $dir);
        my @dp = split(/\//,substr($dir,1));
        my @cd;
        foreach my $sd (@dp) {
                push(@cd,$sd);
                my $cmp = "/".join("/",@cd);
                next if (-d $cmp);
                mkdir($cmp);
                chmod(0777,$cmp);
        }
}


sub tmp_dir {
	return "/dev/shm";
}

sub load_conf {
    my ( $class, @args ) = @_;

    return Fap::ConfLoader->load(@args);
}

##### msg - error message

sub trace_error {
    my ( $class, $msg, %args ) = @_;

    my $error_string = "Error: $msg\n";
    my $level        = 1;
    my $continue     = 1;
    my $padding      = "  ";

    if ( ![ caller(1) ]->[0] ) {
        my @details = caller();
        $error_string .= sprintf( "$padding%s function %s() line %d\n", $details[1], $details[0], $details[2] );
    }
    while ( $continue && ( !defined $args{max_levels} || $level <= $args{max_levels} ) ) {
        my @details = caller($level);
        if ( $details[0] ) {
		my $tmpstr = sprintf( "$padding%s line %d\n", $details[1], $details[2] );
		if ($tmpstr!~/Try\/Tiny|ANON|$args{ignore}/) {
            		$error_string .= $tmpstr;
            		$padding .= "  ";
		}
        } else {
            $continue = 0;
        }
        $level++;
    }
    if ($@) {
        my @lines = split( /\n/, $@ );
        foreach (@lines) {
            $error_string .= "$padding$_\n";
        }
    }
    $@ = $error_string;
    $@=~s/\n\n/\n/g;
}

sub is_development_environment {
    my ( $self, $mode, $hostname ) = @_;

    $hostname ||= Sys::Hostname::hostname();

    if ( $hostname =~ /dev/ && $mode ne "production" ) { return 1; }
    return 0;
}

sub build_java_classpath {
	my ($class,@extra) = @_;
	$ENV{CONF_TARGET} = Fap->path_to("res/conf");
        $ENV{JAVA_HOME} = "/usr/java/latest";
	
        my @dirs = (
		Fap->path_to("lib/java/conf/"),
		glob(Fap->path_to("lib/java/*.jar")),
		map {($_=~/^\//)?"$_":Fap->path_to("$_")} @extra
	);
        my $ret =  join(":",@dirs);
	return $ret;
}
sub build_java_classpath_short {
        my ($class,@extra) = @_;
        $ENV{CONF_TARGET} = "$ENV{FON_DIR}/res/conf";
        $ENV{JAVA_HOME} = "/usr/java/latest";
	@extra = map {($_=~/^\//)?"$_":"$ENV{FON_DIR}/$_"} @extra;
        my @dirs = (
                Fap->path_to("/lib/java/conf/"),
                Fap->path_to("lib/java/*"),
                (map {($_=~/.jar$/i)?"$_":"$_/*"} @extra)
        );
        my $ret =  join(":",@dirs);
        return $ret;
}

sub java {
       my ($class,$javaclass) = @_;
       my $classname = $class."::".join("::",(split(/\./,$javaclass)));
       return $classname;
}


1;
__DATA__
