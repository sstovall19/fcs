mkdir -p [%build_root %][% fon_dir %]
cp -rf --preserve=mode [% copy_root %]* [% build_root %][% fon_dir %]/
mkdir -p [% build_root %][% fonlib_target %]/java
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/lib/* [% build_root %][% fonlib_target %]/java/
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/lib/ext/* [% build_root %][% fonlib_target %]/java/
mkdir -p [% build_root %][% fonlib_target %]/java/conf
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/conf/* [% build_root %][% fonlib_target %]/java/conf
mkdir -p [% build_root %][% bu_target %]/quote/java
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/build/dist/quote/*  [% build_root %][% bu_target %]/quote/java
mkdir -p [% build_root %][% bu_target %]/billing/java
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/build/dist/billing/*  [% build_root %][% bu_target %]/billing/java
mkdir -p [% build_root %][% bu_target %]/shared
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/build/dist/email-notification.jar  [% build_root %][% bu_target %]/shared
cp -rf --preserve=mode [% copy_root %]src/java/core-fsp/build/dist/fonality-fcs.jar  [% build_root%][% fonlib_target %]/java
mkdir -p [% build_root %][% schema_target %]
cp -rf --preserve=mode [% copy_root %]res/data/mysql/* [% copy_root %]res/data/deployment/*  [% build_root %][% schema_target %]
echo "SET FOREIGN_KEY_CHECKS = 0;" > [% build_root %][% schema_target %]/fcs_database.sql
/usr/bin/mysqldump --single-transaction --no-data --skip-triggers -ufonality -piNOcallU -hweb-dev2.fonality.com fcs >> [% build_root %][% schema_target %]/fcs_database.sql
/usr/bin/mysqldump --single-transaction --skip-triggers --compact --no-create-info --ignore-table=fcs.intranet_log --ignore-table=fcs.unbound_cdr_test --ignore-table=fcs.transaction_job --ignore-table=fcs.transcation_submit --ignore-table=fcs.sm_registry -ufonality -piNOcallU -hweb-dev2.fonality.com fcs >> [% build_root %][% schema_target %]/fcs_database.sql
echo "SET FOREIGN_KEY_CHECKS = 1;" >> [% build_root %][% schema_target %]/fcs_database.sql

mkdir -p [% build_root %][% test_dir %]
cp -rf --preserve=mode [% copy_root %]t  [% build_root %][% test_dir %]
mkdir -p [% build_root %][% pdf_dir %]
touch [% build_root %][% pdf_dir %]/.nodelete
mkdir -p [% build_root %]/etc/init.d/
mkdir -p [% build_root %]/etc/default/
cp [% copy_root %]bin/tools/rpmbuild/init [% build_root %]/etc/init.d/fcs
cp [% copy_root %]bin/tools/rpmbuild/defaults [% build_root %]/etc/default/fcs
find [% build_root %] -type d -name \.svn | xargs rm -rf {}\;
rm -rf [% build_root %][% fon_dir %]/src

