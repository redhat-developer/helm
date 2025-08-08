Name:           helm
Version:        %{version}
Release:        1%{?dist}
Summary:        Helm CLI

License:        Apache-2.0
URL:            https://helm.sh/
Source0:        %{name}-%{version}.tar.gz

ExclusiveArch:  x86_64 aarch64 ppc64le s390x

BuildRequires:  golang
BuildRequires:  make
BuildRequires:  rpm-build

%global debug_package %{nil}

%description
Helm is a package manager for Kubernetes. This package provides the Helm command-line interface (CLI).

%prep
%setup -q -n %{name}-%{version}

%build
set -euo pipefail
export CGO_ENABLED=0
export GOFLAGS="-buildvcs=false -mod=vendor"
goarch=amd64
case "%{_target_cpu}" in
  x86_64)  goarch=amd64 ;;
  aarch64) goarch=arm64 ;;
  ppc64le) goarch=ppc64le ;;
  s390x)   goarch=s390x ;;
  *) echo "Unsupported target cpu: %{_target_cpu}" ; exit 1 ;;
esac
export GOOS=linux
export GOARCH="${goarch}"
echo "Building helm for GOOS=${GOOS} GOARCH=${GOARCH}"
go build -trimpath -ldflags "-s -w" ./cmd/helm -o helm

%install
install -D -m 0755 helm "%{buildroot}%{_bindir}/helm"

%files
%license LICENSE
%doc README.md
%{_bindir}/helm

%changelog
* Thu Jan 01 1970 Example Maintainer <noreply@example.com> - %{version}-1
- Initial packaging of Helm CLI



