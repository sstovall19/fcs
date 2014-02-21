#!/bin/sh

export PERL_MM_USE_DEFAULT=1;
sudo yum install mysql-devel openssl-devel expat-devel mod_perl-devel perl-Module-Install htmldoc lighttpd;
perl Makefile.PL --defaultdeps
rc=$?
if [[ $rc != 0 ]] ; then
echo "Error creating Makefile";
exit $rc;
fi
make installdeps;
make clean;
