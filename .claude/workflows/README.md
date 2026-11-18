# Claude Code Workflows

## cve-impact-analysis

Analyzes a CVE for impact across all Helm release branches and produces a structured YAML fix plan.

### Usage

From Claude Code, run:

```
/cve-impact-analysis CVE-2026-128085
```

Or ask Claude to run it:

```
Run the cve-impact-analysis workflow for CVE-2026-128085
```

### What it does

The workflow runs three phases:

1. **Research** — Looks up CVE details via web search: description, severity, CVSS score, CWE, affected packages, fix versions, and whether the CVE affects Helm directly or transitively.

2. **Scan** — Checks all `release-*` branches (from 3.15 onwards) by reading each branch's `go.mod` to find current versions of affected dependencies.

3. **Synthesize** — Produces a YAML fix plan with per-branch remediation steps, including `go get` commands, `go mod tidy`, vendor updates, and a DCO-signed commit message.

### Output

- A summary table showing which branches are affected and which dependencies need bumping
- A full YAML fix plan with step-by-step remediation instructions per branch
- Validation checks to verify the fix was applied correctly

### Requirements

- Claude Code with workflow support
- Access to the Helm git repository with remote branches fetched
