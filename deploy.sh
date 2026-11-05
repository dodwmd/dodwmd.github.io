#!/usr/bin/env bash
# Build the site with Hugo and publish it to the gh-pages branch.
# GitHub Pages is configured to serve that branch (no CI involved).
#
# Usage: ./deploy.sh [--no-push]
set -euo pipefail

cd "$(dirname "$0")"

PUSH=1
[[ "${1:-}" == "--no-push" ]] && PUSH=0

# Re-run inside the nix shell if hugo isn't on PATH (e.g. direnv not loaded).
if ! command -v hugo >/dev/null; then
  if command -v nix-shell >/dev/null && [[ -z "${IN_DEPLOY_NIX_SHELL:-}" ]]; then
    exec env IN_DEPLOY_NIX_SHELL=1 nix-shell --run "$(printf '%q ' "$0" "$@")"
  fi
  echo "hugo not found and nix-shell unavailable" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "Tracked files have uncommitted changes; commit or stash them first so the" >&2
  echo "published site matches a commit on master." >&2
  exit 1
fi

git fetch -q origin gh-pages
SRC_SHA=$(git rev-parse --short HEAD)

WORKTREE=$(mktemp -d)
cleanup() { git worktree remove --force "$WORKTREE" 2>/dev/null || true; }
trap cleanup EXIT

# -B resets the local gh-pages branch to the remote one
git worktree add -q -B gh-pages "$WORKTREE" origin/gh-pages
git -C "$WORKTREE" rm -rq . 
git -C "$WORKTREE" clean -fdxq

HUGO_ENVIRONMENT=production hugo --gc --minify --destination "$WORKTREE"
touch "$WORKTREE/.nojekyll"

git -C "$WORKTREE" add -A
if git -C "$WORKTREE" diff --cached --quiet; then
  echo "No changes to deploy."
  exit 0
fi

git -C "$WORKTREE" commit -q -m "Deploy site from master@${SRC_SHA}"
echo "Committed to gh-pages: $(git -C "$WORKTREE" log -1 --format=%h)"

if (( PUSH )); then
  git -C "$WORKTREE" push origin gh-pages
  echo "Pushed. GitHub Pages will update shortly."
else
  echo "Skipped push (--no-push). Run: git push origin gh-pages"
fi
