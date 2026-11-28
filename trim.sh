#!/usr/bin/env bash
# trim.sh — turn upstream academic-research-skills into a Reasonix-installable plugin.
#
# Run it from the ROOT of an upstream clone (symlinks must be real symlinks,
# so run on a Linux runner, not a Windows checkout):
#     bash /path/to/trim.sh
#
# It keeps everything the skills reference at runtime and removes
# dev/CI/test-only content. The builder files (trim.sh + .github/workflows/)
# are NOT part of the upstream tree and are restored by the workflow afterwards.
set -euo pipefail

echo "== [1/5] flatten skills/<name> symlinks into real directories =="
for s in skills/*; do
  [ -e "$s" ] || [ -L "$s" ] || continue
  name="$(basename "$s")"
  if [ -L "$s" ]; then
    target="$(readlink "$s")"
    real="$(cd "$(dirname "$s")" && cd "$target" && pwd)"
    rm -f "$s"
    mv "$real" "skills/$name"
    echo "    flattened skills/$name (was symlink -> $target)"
  fi
done

echo "== [2/5] remove dev/CI/test trees =="
rm -rf evals tests audits tools pi examples .github
# note: 'examples' above is the top-level showcase dir; per-skill examples/ stay.

echo "== [3/5] trim scripts/ =="
rm -rf scripts/adapters scripts/fixtures scripts/legacy scripts/cross_model_verification
rm -f scripts/test_*.py \
      scripts/run_evals.py \
      scripts/plot_*.py \
      scripts/make_table2.py \
      scripts/render_eval_comment.py \
      scripts/migrate_*.py \
      scripts/*_smoke_test*.sh \
      scripts/run_ci_pytest_manifest.py \
      scripts/check_ci_pytest_manifest.py \
      scripts/sync_adapter_docs.py \
      scripts/_ci_pytest_manifest.toml

echo "== [4/5] trim docs/ =="
rm -rf docs/design/snapshots docs/migration docs/superpowers docs/claude-code
rm -f docs/PERFORMANCE.md docs/PERFORMANCE.zh-TW.md \
      docs/SETUP.md docs/SETUP.zh-TW.md \
      docs/ARCHITECTURE.md docs/cross-paper-workflow.md docs/ROADMAP*.md

echo "== [5/5] remove dev-only root files + rewrite README =="
rm -f CHANGELOG.md CONTRIBUTING.md MODE_REGISTRY.md POSITIONING.md QUICKSTART.md \
      SECURITY.md THIRD_PARTY.md \
      README.ja-JP.md README.ko-KR.md README.zh-CN.md README.zh-TW.md \
      package.json pyproject.toml requirements-dev.txt \
      .gitleaks.toml .gitleaksignore .command-invariants.toml .gitattributes .gitignore

VERSION="$(python3 -c 'import json;print(json.load(open(".claude-plugin/plugin.json"))["version"])')"
cat > README.md <<'README_EOF'
# academic-research-skills — trimmed build for Reasonix

This repository is a trimmed redistribution of the upstream
[`Imbad0202/academic-research-skills`](https://github.com/Imbad0202/academic-research-skills)
plugin (version `__VERSION__`), repackaged so it can be installed as a plugin in
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
README_EOF
sed -i "s/__VERSION__/$VERSION/" README.md

echo "== done =="
