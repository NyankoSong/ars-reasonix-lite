# academic-research-skills — trimmed build for Reasonix

This repository is a trimmed redistribution of the upstream
[`Imbad0202/academic-research-skills`](https://github.com/Imbad0202/academic-research-skills)
plugin (version `3.22.2`), repackaged so it can be installed as a plugin in
[Reasonix](https://reasonix.io).

> Original author: Cheng-I Wu (https://github.com/Imbad0202)
> Original license: CC BY-NC-4.0 (non-commercial). See LICENSE.

## Why this build exists

The upstream repository cannot be installed into Reasonix directly, for two reasons:

1. **Per-skill-directory size limit.** Reasonix's installer rejects any skill
   directory larger than 20 MiB (`skill directory exceeds 20971520 bytes`). The
   upstream `skills/` symlinks are resolved in a way that trips this limit.
2. **Symlinks.** Upstream `skills/<name> -> ../<name>` symlink entries are fragile
   on Windows and confuse Reasonix's installer.

## What was trimmed

- Flattened the `skills/<name>` symlinks into real directories (the real skill
  directories were moved into `skills/`).
- Removed dev/CI/test-only content: `evals/`, `tests/`, `audits/`, `tools/`,
  `pi/`, the upstream `.github/`, the top-level `examples/`, `scripts/test_*.py`,
  `scripts/adapters/`, `scripts/fixtures/`, `scripts/legacy/`, `docs/snapshots/`,
  and assorted dev-only root files.
- Rewrote this README (the upstream one described the full project).

Everything the skills reference at runtime is kept intact: `shared/`, `scripts/`,
`docs/design/`, `.claude/`, `agents/`, `commands/`, and `hooks/`.

## How this build is produced

A GitHub Actions workflow (`.github/workflows/sync.yml`) clones upstream `main`
on a schedule and on demand, runs `trim.sh`, and force-pushes the result here.
`trim.sh` and the workflow are kept in this repository so the build can
regenerate itself. Do not edit the trimmed skill content here — upstream edits
belong in the original repository.

## License

Upstream is **CC BY-NC-4.0** (non-commercial). This redistribution keeps the same
license and attribution. Commercial use requires permission from the original
author, Cheng-I Wu (https://github.com/Imbad0202).
