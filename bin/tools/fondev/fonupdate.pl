#!/usr/bin/perl -w 

use strict;
use YAML qw(Load);
use Data::Dumper;
use CPAN;
use FindBin qw($Bin);
use File::Slurp;

# This is voodoo magic that causes fonupdate to run the latest version of itself. Oh, the humanity...

if ( defined( caller() ) ) {
    my $svn =
`svn --no-auth-cache --username ec2 --password 'traffic pork blossom' cat https://svn.fonality.com/src/fcs/trunk/res/conf/code/dependencies.conf`
      . "\n";
    my $dep       = Load($svn);
    my $yum_deps  = $dep->{yum_dependencies};
    my $perl_deps = $dep->{perl_dependencies};
    my @requires;
    $ENV{'JAVA_HOME'}           = "/usr/java/latest";
    $ENV{"PERL_MM_USE_DEFAULT"} = 1;
    if ( system("rpm -q --quiet rpmforge-release") != 0 ) {
        system(
"yum install -y http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm"
        );
    }

    foreach my $rpm_dependency (@$yum_deps) {
        if ( system("rpm -q --quiet $rpm_dependency") != 0 ) {
            if ( system("yum install -y $rpm_dependency") != 0 ) {
                die(
"Error installing dependency $rpm_dependency. Try agan and if it still doesn't work we can troubleshoot.\n"
                );
            }
        }
    }
    foreach my $perl_module ( keys %$perl_deps ) {
        my $dependency;
        eval("require $perl_module;");
        if ($@) {
            CPAN::Shell->install($perl_module);
            eval("require $perl_module;");
            if ($@) {
                die(
"Error installing CPAN module $perl_module. Oops. Try again. If it still doesn't work we can troubleshoot.\n"
                );
            }
        }
    }

    write_file( "/etc/fondev/dependencies.conf", $svn )
      or die("Copy failed: $!");
    print("FONupdate was successful.\n");
    exit(0);

}
else {
    my $script_contents =
`svn --no-auth-cache --username ec2 --password 'traffic pork blossom' cat https://svn.fonality.com/src/fcs/trunk/bin/tools/fondev/fonupdate.pl`
      . "\n";
    eval($script_contents);
    if ($@) {
        die($@);
    }
}
