# CLAUDE.md — Agent Context for redhat-developer/helm

## Project overview

Red Hat's downstream build of [Helm](https://github.com/helm/helm). This is
not a fork — it is a rebuild with Red Hat's base image and FIPS compliance.
The upstream Helm source is vendored and patched per release branch. The main
branch tracks upstream Helm v4 development.

## Build commands

```bash
make build          # Build the helm binary to bin/helm
make test           # Run linter (golangci-lint) + unit tests
make test-unit      # Unit tests only
make test-style     # golangci-lint run ./... + license header check
make build-cross    # Cross-compile for all supported platforms
make format         # Run goimports
```

CI runs `make test-coverage` and `make build` via `.github/workflows/build-test.yml`.
Linting uses golangci-lint v2 (config in `.golangci.yml`).

### FIPS builds (release branches only)

Release branches (e.g. `release-3.21`) add FIPS 140 compliance:
- `go.mod` includes `godebug fips140=auto`
- Makefile sets `GOFIPS140 ?= certified` and prepends it to build targets

The `main` branch (Helm v4) does not currently use FIPS flags.

## Test commands

```bash
go test ./...                              # All unit tests
go test ./pkg/action/...                   # Single package
go test -run TestSpecificFunc ./pkg/cmd/   # Single test
make test-coverage                         # Unit tests with coverage report
make gen-test-golden                       # Regenerate golden files for cmd/action tests
```

Tests use the `testify` assertion library (`github.com/stretchr/testify`).

## Dependency management

Dependencies are managed with Go modules. The `main` branch does **not**
vendor dependencies (no `vendor/` directory). Release branches may vendor
via `go mod vendor`.

```bash
go mod tidy        # Clean up go.mod/go.sum
go mod vendor      # Vendor dependencies (release branches only)
```

When bumping dependencies, ensure `go.sum` checksums are consistent and
`go.mod` changes are minimal (only the intended dependency).

## Branch strategy

| Branch | Purpose |
|--------|---------|
| `main` | Default branch. Helm v4 development (unstable) |
| `release-X.Y` | Track upstream Helm releases for Red Hat rebuilds |

PRs often target `release-X.Y` branches rather than `main`. When creating
a PR, check the issue for the target branch — it may specify a release
branch (e.g. "apply to release-3.21").

Helm v3 stable development continues on `dev-v3`. Bug fixes go to v4
(`main`) first, then get backported to v3.

## Downstream integration

- **Jira tickets**: Referenced as `HELM-xxx` or `OCPTOOLS-xxx` in issues
  and PR descriptions
- **OCP target versions**: PRs note the target OpenShift version
  (e.g. `ocp-tools-4.22`)
- **Post-merge workflow**: After a PR merges, update `upstream_sources.yml`
  in the midstream repo, then run check-patch and Brew builds
- **Scratch/Brew builds**: `check-patch` validates the build before the
  full `build-pipeline` Brew build

## Review guidance for dependency bumps

When reviewing vendored dependency bumps:

1. Verify `go.sum` checksums are consistent with the declared version
2. Confirm vendored code matches the declared module version
3. Check that no unrelated source changes are included
4. Validate the CVE or security advisory justifying the bump
5. Ensure the Go directive and K8s API versions are unchanged unless
   intentionally updated
