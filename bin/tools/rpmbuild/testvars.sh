#!/bin/bash





eval `sed -n -E 's/export ([A-Za-z_]*)=.*/unset \1/p' fcs/bin/tools/rpmbuild/defaults`
export CWD=`pwd -P`
export TEST_DIR="$PWD/test/root"
export FON_DIR="$PWD/test/usr/local/fonality"
export FCS_TEST=1
source fcs/bin/tools/rpmbuild/defaults
export FCS_DB_USER=fonality
export FCS_DB_PASS=iNOcallU
export FCS_DB_NAME=fcstest
export FCS_DB_HOST=cfg1
echo "DROP DATABASE fcstest ">mysql -u$FCS_DB_USER -p$FCS_DB_PASS -h$FCS_DB_HOST $FCS_DB_NAME
echo "CREATE DATABASE fcstest" >mysql -u$FCS_DB_USER -p$FCS_DB_PASS -h$FCS_DB_HOST $FCS_DB_NAME
mysql -u$FCS_DB_USER -p$FCS_DB_PASS -h$FCS_DB_HOST $FCS_DB_NAME < "$SCHEMA_TARGET/fcs_database.sql"
if [ -d $PWD/junit_output ]; then 
rm -rf $PWD/junit_output
fi
mkdir -p $PWD/junit_output
export PERL_TEST_HARNESS_DUMP_TAP="$PWD/junit_output"
bash "$TEST_DIR/t/run_tests"
