This repository is used to create releases of the Red Hat build of the Helm CLI.

As such, this repository is not quite a fork of the upstream helm/helm repository,
particularly in the sense that we do not pull branches from this repo back to the
upstream.  We use upstream release branches/tags to create downstream branches to
which we add local changes for building, local fixes, and (possibly someday) local
enhancements.

So, for the most part, the branches in this repository track and extend the
branches in the upstream repo.  As such, no local commits should be added to the
upstream branches, _including `main`_.  Local commits should be maintained in
local branches either orphans or based on upstream branches.

For that reason, the default branch for this repo is `default` and not `main`,
because `main` tracks the upstream repo's `main`.  This branch is where we keep
items of global impact, such as the Fullsend configuration.

The other branches of note follow the pattern, `downstream-patches-*`.  These
commits contain modifications required to convert an upstream release branch into
a downstream release branch.  These branches are based on the most recent upstream
release branch, and they are rebased as new upstream releases are created.  This
maintains the merge resolutions as a minimum set.  When a new downstream release
is created, the entire patches branch, from its upstream branch point to its tip,
should be cherry-pick'd on to the new downstream release branch.  As new changes
are required for the patches, they can be committed to the patches branch, and
then the patches branch can be re-cherry-pick'd to the various release branches.
In this way, the patch branch forms a single source of truth for the patches.
