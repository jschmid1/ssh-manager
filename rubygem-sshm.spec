#
# spec file for package rubygem-ssh-manager (Version 0.0.8)
#
# Copyright (c) 2009 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild
Name:           rubygem-ssh-manager
Version:        0.0.8
Release:        0
%define mod_name ssh-manager
#
Group:          Development/Languages/Ruby
License:        GPLv2+ or Ruby
#
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildRequires:  rubygems_with_buildroot_patch
Requires:       rubygems >= 2.0.0
BuildRequires:  ruby2.0-rubygem-sequel 
Requires:       ruby2.0-rubygem-sequel 
BuildRequires:  rubygem-sqlite3 
Requires:       rubygem-sqlite3 
BuildRequires:  rubygem-rake 
Requires:       rubygem-rake 
#
Url:            https://rubygems.org/profiles/jschmid
Source:         %{mod_name}-%{version}.gem
#
Summary:        manage and connect ssh
%description
Manage ssh connections.


%prep
%build
%install
%gem_install %{S:0}


%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)

%{_bindir}/sshm

%{_libdir}/ruby/gems/%{rb_ver}/cache/%{mod_name}-%{version}.gem
%{_libdir}/ruby/gems/%{rb_ver}/gems/%{mod_name}-%{version}/
%{_libdir}/ruby/gems/%{rb_ver}/specifications/%{mod_name}-%{version}.gemspec
%doc %{_libdir}/ruby/gems/%{rb_ver}/doc/%{mod_name}-%{version}/

%changelog
