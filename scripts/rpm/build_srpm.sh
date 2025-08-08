#!/usr/bin/env bash
set -euo pipefail

# Inputs (environment):
#   VERSION     - version string (e.g., 3.18.0)
#   TOPDIR      - top-level working directory (rpmbuild tree will be created under this)
#   SOURCE_DIR  - path to repository root (containing packaging/helm.spec)

VERSION=${VERSION:-}
TOPDIR=${TOPDIR:-}
SOURCE_DIR=${SOURCE_DIR:-}

if [[ -z "${VERSION}" || -z "${TOPDIR}" || -z "${SOURCE_DIR}" ]]; then
  echo "ERROR: VERSION, TOPDIR, and SOURCE_DIR must be set" >&2
  exit 1
fi

RPMTOP="${TOPDIR}/rpmbuild"
mkdir -p "${RPMTOP}"/{BUILD,BUILDROOT,RPMS,SRPMS,SOURCES,SPECS}

# Create source tarball helm-${VERSION}.tar.gz excluding .git and vendor/.git
TAR_DIR="$(mktemp -d)"
trap 'rm -rf "${TAR_DIR}"' EXIT
rsync -a --delete --exclude ".git" --exclude "vendor/.git" "${SOURCE_DIR}/" "${TAR_DIR}/helm-${VERSION}/"
tar -C "${TAR_DIR}" -czf "${RPMTOP}/SOURCES/helm-${VERSION}.tar.gz" "helm-${VERSION}"

# Copy spec into SPECS
cp -f "${SOURCE_DIR}/packaging/helm.spec" "${RPMTOP}/SPECS/helm.spec"

# Build SRPM
rpmbuild \
  -D "_topdir ${RPMTOP}" \
  -D "version ${VERSION}" \
  -bs "${RPMTOP}/SPECS/helm.spec"

# Collect SRPM and checksums
OUT_DIR="${TOPDIR}/output/rpms"
mkdir -p "${OUT_DIR}/SRPMS"
SRPM_FILE=$(ls -1t "${RPMTOP}/SRPMS"/helm-*.src.rpm | head -n1)
if [[ -z "${SRPM_FILE:-}" ]]; then
  echo "ERROR: SRPM was not produced" >&2
  exit 1
fi
cp -f "${SRPM_FILE}" "${OUT_DIR}/SRPMS/"

cd "${OUT_DIR}"
LC_ALL=C ls -1 SRPMS/*.src.rpm | LC_ALL=C sort | xargs -r sha256sum > sha256sum.txt
echo "SRPM and checksum written to ${OUT_DIR}";


