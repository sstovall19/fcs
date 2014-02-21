package Fap::Util::Dependencies;
use strict;
use Fap::ConfLoader;
use Fap;
use Term::ReadLine;
use Cwd;

my $cwd = my $uwd = getcwd;
my $term  = Term::ReadLine->new("Generate Files For Perl Install");
my $uwd   = $ARGV[0] || Fap->path_to( "res", "data", "deployment" );
my $valid = 0;

my $deps = Fap::ConfLoader->load("code/dependencies");

print STDERR "\nWriting Makefile.PL\n";
open( FO, ">$uwd/Makefile.PL" );
print FO "#!/usr/bin/perl\nuse inc::Module::Install;\n";
print FO sprintf( "name '%s';\n",         $deps->{name} );
print FO sprintf( "version '%0.2d';\n\n", $deps->{version} );
foreach my $mod ( keys %{ $deps->{perl_dependencies} } ) {
    print FO sprintf( "requires '%s' , '%s';\n", $mod, $deps->{perl_dependencies}->{$mod} );
}
print FO qq(auto_install(make_args=>"--build_requires_install_policy yes");\n);
print FO "WriteAll();\n";
close(FO);
chmod( 0755, "\n$uwd/Makefile.PL" );

print STDERR "Writing install_deps.sh\n";
open( FO, ">$uwd/install_deps.sh" );
print FO "#!/bin/sh\n\n";
print FO sprintf( "export PERL_MM_USE_DEFAULT=1;\nsudo yum install %s;\n", join( " ", @{ $deps->{yum_dependencies} } ) );
print FO "perl Makefile.PL --defaultdeps\n";
print FO qq(rc=\$?\n);
print FO qq(if [[ \$rc != 0 ]] ; then\n);
print FO qq(echo "Error creating Makefile";\n);
print FO qq(exit \$rc;\n);
print FO qq(fi\n);
print FO qq(make installdeps;\n);
print FO qq(make clean;\n);
close(FO);
chmod( 0755, "$uwd/install_deps.sh" );

print STDERR "\n\nExecute\n\n sh $uwd/install_deps.sh\n\nto install new dependencies\n\n";

exit;

1;
__DATA__

