#debuginfo not supported with Go
%global debug_package %{nil}
%global package_name helm
%global product_name OpenShift Tools and Services
%global golang_version 1.13
%global helm_version 3.1.1
%global helm_release 1
%global source_dir helm-v%{helm_version}-%{helm_release}
%global source_tar %{source_dir}.tar.gz

Name:           %{package_name}
Version:        %{helm_version}
Release:        %{helm_release}%{?dist}
Summary:        %{product_name} helm binary for rhose 4.3
License:        ASL 2.0
URL:            https://github.com/redhat-developer/helm/tree/release-3.0

ExclusiveArch:  x86_64

Source0:        %{source_tar}
BuildRequires:  gcc
BuildRequires:  golang >= %{golang_version}
Provides:       %{package_name}
Obsoletes:      %{package_name}

%description
OpenShift helm is tool for managing Charts in OpenShift. Charts are packages of pre-configured OpenShift Resources

%prep
%setup -q -n helm
mkdir -p %{_builddir}/src/helm.sh
rm -rf %{_builddir}/src/helm.sh/helm
cp -rf %{_builddir}/helm %{_builddir}/src/helm.sh

%build
cd %{_builddir}/src/helm.sh/helm
TAG=%{helm_version} GOPATH=%{_builddir} make build-cross

%install
mkdir -p %{buildroot}%{_bindir}
install -m 0755 %{_builddir}/src/helm.sh/helm/_dist/linux-amd64/helm %{buildroot}%{_bindir}

install -d %{buildroot}%{_datadir}/%{name}-redistributable/{linux,macos,windows,ppc64le,s390x}
install -p -m 0755 %{_builddir}/src/helm.sh/helm/_dist/linux-amd64/helm %{buildroot}%{_datadir}/%{name}-redistributable/linux/helm-linux-amd64
install -p -m 0755 %{_builddir}/src/helm.sh/helm/_dist/darwin-amd64/helm %{buildroot}%{_datadir}/%{name}-redistributable/macos/helm-darwin-amd64
install -p -m 0755 %{_builddir}/src/helm.sh/helm/_dist/windows-amd64/helm.exe %{buildroot}%{_datadir}/%{name}-redistributable/windows/helm-windows-amd64.exe
install -p -m 0755 %{_builddir}/src/helm.sh/helm/_dist/linux-ppc64le/helm %{buildroot}%{_datadir}/%{name}-redistributable/ppc64le/helm-linux-ppc64le
install -p -m 0755 %{_builddir}/src/helm.sh/helm/_dist/linux-s390x/helm %{buildroot}%{_datadir}/%{name}-redistributable/s390x/helm-linux-s390x

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
%dir %{_datadir}/%{name}-redistributable/ppc64le/
%dir %{_datadir}/%{name}-redistributable/s390x/
%{_datadir}/%{name}-redistributable/linux/helm-linux-amd64
%{_datadir}/%{name}-redistributable/macos/helm-darwin-amd64
%{_datadir}/%{name}-redistributable/windows/helm-windows-amd64.exe
%{_datadir}/%{name}-redistributable/ppc64le/helm-linux-ppc64le
%{_datadir}/%{name}-redistributable/s390x/helm-linux-s390x


%changelog
* Tue Feb 25 2020 Bama Charan Kundu <bkundu@redhat.com> v3.1.1-1
- Tech preview release for helm 3.1
* Fri Dec 20 2019 Bama Charan Kundu <bkundu@redhat.com> v3.0.0-1
- Initial tech preview release
