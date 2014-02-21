Name:		fcs
Version:	[% version %]
Release:	1
BuildArch: noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
AutoReqProv: no
Source: fcs.tgz
Summary: FCS
License: Copyright 2005-2012 Fonality, Inc
Group: Fonality


Requires:	[% requires %]

%description

%prep
%setup -q

%build
#java building stuff might go here

%install
[% install_script %]

%files
%defattr(-, root, root, -)
[% fon_dir %]/*
[% test_dir %]/*
%dir [% sm_target %]
/etc/init.d/fcs
%config /etc/default/fcs
%post
sed -i '/FCS_TESTED/d' /etc/default/fcs
echo "export FCS_TESTED=\"false\"" >> /etc/default/fcs
service fcs reloaddb
