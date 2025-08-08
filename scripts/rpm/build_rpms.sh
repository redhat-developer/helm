#!/usr/bin/env bash
set -euo pipefail

# Inputs
#   VERSION:     version string for the RPMs
#   TOPDIR:      top directory for rpmbuild workspace (will create rpmbuild tree under this)
#   SOURCE_DIR:  path to the source repository (containing packaging/helm.spec)

VERSION=${VERSION:-}
TOPDIR=${TOPDIR:-}
SOURCE_DIR=${SOURCE_DIR:-}

if [[ -z "${VERSION}" || -z "${TOPDIR}" || -z "${SOURCE_DIR}" ]]; then
  echo "ERROR: VERSION, TOPDIR, and SOURCE_DIR must be set" >&2
  exit 1
fi

echo "Building SRPM and RPMs for helm version ${VERSION}"

RPMTOP="${TOPDIR}/rpmbuild"
mkdir -p "${RPMTOP}"/{BUILD,BUILDROOT,RPMS,SRPMS,SOURCES,SPECS}

# Create a source tarball from SOURCE_DIR
WORK_TARBALL="${RPMTOP}/SOURCES/helm-${VERSION}.tar.gz"
TAR_TMP="$(mktemp -d)"
trap 'rm -rf "${TAR_TMP}"' EXIT

rsync -a --delete --exclude ".git" --exclude "vendor/.git" "${SOURCE_DIR}/" "${TAR_TMP}/helm-${VERSION}/"
tar -C "${TAR_TMP}" -czf "${WORK_TARBALL}" "helm-${VERSION}"

# Copy spec
cp -f "${SOURCE_DIR}/packaging/helm.spec" "${RPMTOP}/SPECS/helm.spec"

# Build SRPM
SRPM_OUT_DIR="${RPMTOP}/SRPMS"
rpmbuild \
  -D "_topdir ${RPMTOP}" \
  -D "version ${VERSION}" \
  -bs "${RPMTOP}/SPECS/helm.spec"

SRPM_FILE=$(ls -1t "${SRPM_OUT_DIR}"/helm-*.src.rpm | head -n1)
if [[ -z "${SRPM_FILE:-}" ]]; then
  echo "ERROR: SRPM was not produced" >&2
  exit 1
fi
echo "SRPM: ${SRPM_FILE}"

# Attempt to rebuild for multiple architectures (best-effort)
declare -a arches=(x86_64 aarch64 ppc64le s390x)
BIN_RPMS_DIR="${RPMTOP}/RPMS"
declare -a produced_rpms=()

for arch in "${arches[@]}"; do
  echo "Rebuilding for ${arch}"
  set +e
  rpmbuild --rebuild \
    -D "_topdir ${RPMTOP}" \
    -D "version ${VERSION}" \
    --target "${arch}" \
    "${SRPM_FILE}"
  rc=$?
  set -e
  if [[ $rc -eq 0 ]]; then
    found=("${BIN_RPMS_DIR}/${arch}/helm-"*".rpm")
    for f in "${found[@]}"; do
      if [[ -f "$f" ]]; then
        produced_rpms+=("$f")
      fi
    done
  else
    echo "WARN: Cross-rebuild for ${arch} failed; SRPM remains available for Brew/Koji to build."
  fi
done

# Collect outputs
OUT_DIR="${TOPDIR}/output/rpms"
mkdir -p "${OUT_DIR}/SRPMS"
cp -f "${SRPM_FILE}" "${OUT_DIR}/SRPMS/"

for arch in "${arches[@]}"; do
  rpmpath="${BIN_RPMS_DIR}/${arch}/helm-"*".rpm"
  if compgen -G "${rpmpath}" > /dev/null; then
    cp -f ${rpmpath} "${OUT_DIR}/"
  fi
done

cd "${OUT_DIR}"
LC_ALL=C ls -1 SRPMS/*.src.rpm *.rpm 2>/dev/null | LC_ALL=C sort | xargs -r sha256sum > sha256sum.txt
echo "Artifacts written to ${OUT_DIR}";


