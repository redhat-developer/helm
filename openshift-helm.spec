#debuginfo not supported with Go
%global debug_package %{nil}
%global package_name helm
%global product_name OpenShift Container Platform
%global golang_version 1.12
%global helm_version 3.0.1
%global helm_release 1
%global source_dir helm-v%{helm_version}-%{helm_release}
%global source_tar %{source_dir}.tar.gz

Name:           %{package_name}
Version:        %{helm_version}
Release:        %{helm_release}
Summary:        %{product_name} helm binary for rhose 4.3
License:        Apache License Version 2.0
URL:            https://github.com/redhat-developer/helm/tree/rhose-4.3

ExclusiveArch:  x86_64

Source0:        %{source_tar}
BuildRequires:  gcc
BuildRequires:  golang >= %{golang_version}
Provides:       %{package_name}
Obsoletes:      %{package_name}

%description
OpenShift helm is tool for managing Charts in OpenShif. Charts are packages of pre-configured OpenShift Resources

%prep
%setup -q -n helm
mkdir -p %{_builddir}/src/helm.sh
rm -rf %{_builddir}/src/helm.sh/helm
mv %{_builddir}/helm %{_builddir}/src/helm.sh
cd %{_builddir}/src/helm.sh/helm

%build
TAG=%{helm_version} GOPATH=%{_builddir} make build-cross

%install
mkdir -p %{buildroot}/%{_bindir}
install -m 0755 helm-linux-amd64 %{buildroot}/%{_bindir}/helm

install -d %{buildroot}%{_datadir}/%{name}-redistributable/{linux,macos,windows}
install -p -m 755 helm-linux-amd64 %{buildroot}%{_datadir}/%{name}-redistributable/linux/helm-linux-amd64
install -p -m 755 helm-darwin-amd64 %{buildroot}/%{_datadir}/%{name}-redistributable/macos/helm-darwin-amd64
install -p -m 755 helm-windows-amd64.exe %{buildroot}/%{_datadir}/%{name}-redistributable/windows/helm-windows-amd64.exe

%files
%license LICENSE
%{_bindir}/helm

%package redistributable
Summary:        %{product_name} helm binaries for Linux, Mac OSX, and Windows
BuildRequires:  gcc
BuildRequires:  golang >= %{golang_version}
Provides:       %{package_name}-redistributable
Obsoletes:      %{package_name}-redistributable

%description redistributable
%{product_name} helm cross platform binaries for Linux, macOS and Windows.

%files redistributable
%license LICENSE
%dir %{_datadir}/%{name}-redistributable/linux/
%dir %{_datadir}/%{name}-redistributable/macos/
%dir %{_datadir}/%{name}-redistributable/windows/
%{_datadir}/%{name}-redistributable/linux/helm-linux-amd64
%{_datadir}/%{name}-redistributable/macos/helm-darwin-amd64
%{_datadir}/%{name}-redistributable/windows/helm-windows-amd64.exe

%changelog
* Thu Sep 05 2019 Bama Charan Kundu <bkundu@redhat.com> v3.0.1-1
- Initial tech preview release

