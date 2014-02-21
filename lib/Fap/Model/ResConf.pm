package Fap::Model::ResConf;
use strict;
use YAML();
use Storable ();
use Data::MessagePack;
use Data::Dumper;
use File::stat;
use File::Slurp;
use Fap;

sub load {
    my ( $class, $conf, $path ) = @_;

    my $confdir = $path || Fap->path_to( "res", "conf" );
    my $compiled_dir = "/dev/shm/conf";
    my $obj;
	my $e = File::stat::stat("$compiled_dir/$conf.mp");
    if ( -e "$compiled_dir/$conf.mp" && -e "$compiled_dir/$conf.conf" ) {
		if (File::stat::stat("$confdir/$conf.conf")->mtime > File::stat::stat("$compiled_dir/$conf.mp")->mtime ) {
			$obj = YAML::LoadFile("$confdir/$conf.conf");
			check_dir("$compiled_dir/$conf.mp");
			File::Slurp::write_file( "$compiled_dir/$conf.mp", { binmode => ':raw' }, Data::MessagePack->pack($obj) );
			chmod(0666, "$compiled_dir/$conf.mp");
	
		} else {
			$obj = Data::MessagePack->unpack( File::Slurp::read_file( "$compiled_dir/$conf.mp", { binmode => ':raw' } ) );
		}
	} else {
		$obj = Data::MessagePack->unpack( File::Slurp::read_file( "$compiled_dir/$conf.mp", { binmode => ':raw' } ) );
	}
    if ( $obj->{includes} ) {
        foreach my $key ( keys %{ $obj->{includes} } ) {
            $obj->{$key} = $class->load( $obj->{includes}->{$key} );
        }
        delete $obj->{includes};
    }
    return $obj;
}
sub check_dir {
	my ($file) = @_;

	my $dir = substr($file,0,rindex($file,"/"));
	return if (-e $dir);
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
sub write_conf {
	my ($file,$data) = @_;

}
	
1;
__DATA__
