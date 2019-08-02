Name:           repo-tools
Version:        20190802
Release:        0
Summary:        Various tools for RPM (repomd) repositories
License:        GPL-2.0
Group:          System/Packages
Url:            https://github.com/ikapelyukhin/repo-tools
Source0:        repo-tools-%{version}.tar.bz2
Requires:       rubygem(repomd_parser)
Requires:       rubygem(typhoeus)
Requires:       rubygem(progressbar)
BuildArch:      noarch

%description
Various tools for RPM (repomd) repositories

%prep
%setup -q
sed -i 's|/usr/bin/env ruby|/usr/bin/ruby|' *.rb

%build

%install
pwd
ls -la
mkdir -p %{buildroot}/usr/share/repo-tools
install -D -m755 *.rb %{buildroot}/usr/share/repo-tools

%files
%defattr(-,root,root)
%dir /usr/share/repo-tools
/usr/share/repo-tools/*.rb

%changelog
