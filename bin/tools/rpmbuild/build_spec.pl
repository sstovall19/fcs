#!/usr/bin/perl

use Env;
use warnings;
use Template;
use YAML qw(LoadFile);
use strict;
use Data::Dumper;

my $tpl_vars;
my $fcs_dir="fcs/";
my $install_script = "";
my $version;
if(scalar @ARGV > 0){
$version = $ARGV[0];
} else {
$version = time();
}
sub get_dependencies {
my $filename = shift(@_);
my $dep = LoadFile($filename);
my $yum_deps = $dep->{yum_dependencies};
my $perl_deps = $dep->{perl_dependencies};
my @requires;

foreach my $rpm_dependency (@$yum_deps){
push(@requires, $rpm_dependency);

}
foreach my $perl_module (keys %$perl_deps)
{
my $dependency;
$dependency = "perl(" . $perl_module . ")";
# if($perl_deps->{$perl_module} ne 0){$dependency = $dependency . " >= " . $perl_deps->{$perl_module};}
# push(@requires,$dependency);
# we need to fix this
}
return @requires;
}
#print Dumper(@requires);
#$tpl_vars->{'requires'} = join(', ',@requires);


my $tt = Template->new() || die "$Template::ERROR\n";

$tpl_vars->{'version'} = $version;
$tpl_vars->{'requires'} = join(', ',get_dependencies($fcs_dir.'/res/conf/code/dependencies.conf'));
$tpl_vars->{'subversion_rev'} = `svnversion $fcs_dir`;
chomp($tpl_vars->{'subversion_rev'});
$tpl_vars->{'build_dir'} = $ENV{'BUILDDIR'};
$tpl_vars->{'fonlib_target'} = $ENV{'FONLIB_TARGET'};
$tpl_vars->{'bu_target'} = $ENV{'BU_TARGET'};
$tpl_vars->{'schema_target'} = $ENV{'SCHEMA_TARGET'};
$tpl_vars->{'res_target'} = $ENV{'RES_TARGET'};
$tpl_vars->{'bin_target'} = $ENV{'BIN_TARGET'};
$tpl_vars->{'test_dir'} = $ENV{'TEST_DIR'};
$tpl_vars->{'conf_target'} = $ENV{'CONF_TARGET'};
$tpl_vars->{'pdf_dir'} = $ENV{'PDF_DIR'};
$tpl_vars->{'fon_dir'} = $ENV{'FON_DIR'};
$tpl_vars->{'build_root'} = '%{buildroot}';
$tpl_vars->{'copy_root'} = '';
$tt->process('env.tpl', $tpl_vars,\$install_script);
$tpl_vars->{'install_script'} = $install_script;
$tt->process('spec.tpl', $tpl_vars,'fcs.spec');
$tpl_vars->{'build_root'} = './test';
$tpl_vars->{'copy_root'} = 'fcs/';
$tt->process('env.tpl', $tpl_vars,'testenv.sh');
