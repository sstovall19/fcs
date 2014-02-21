#!/bin/bash

RPMDIR=$HOME/.rpm
mkdir -p build
svn -q co svn+ssh://svn/fcs/trunk/ build/fcs/
VERSION=r`svnversion build/fcs/`.`date +%Y%m%d.%H%M%S%Z`
. build/fcs/tools/rpmbuild/defaults
cp build/fcs/tools/rpmbuild/build_spec.pl build/build_spec.pl
cp build/fcs/tools/rpmbuild/spec.tpl build/
cd build/
cp -R fcs fcs-$VERSION
tar -czf $RPMDIR/SOURCES/fcs.tgz fcs-$VERSION
rm -rf fcs-$VERSION
perl build_spec.pl $VERSION
rpmbuild --quiet -bb fcs.spec && echo -e "RPM built to :\n$RPMDIR/RPMS/noarch/fcs-$VERSION.noarch.rpm"
cd .. && rm -rf build/
rm -f $RPMDIR/SOURCES/fcs.tgz

