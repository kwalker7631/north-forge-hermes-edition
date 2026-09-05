#!/usr/bin/env sh
# Fail fast if local per-drive state or the secret environment file can be committed.
set -eu

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

git check-ignore --quiet .provider-choice || {
    echo "ERROR: .provider-choice must remain ignored as per-drive state." >&2
    exit 1
}

git check-ignore --quiet .env || {
    echo "ERROR: .env must remain ignored because it can contain secrets." >&2
    exit 1
}

if ! git diff --cached --quiet -- .env; then
    echo "ERROR: .env is staged. Unstage it before continuing." >&2
    exit 1
fi

echo "Repository hygiene checks passed: .provider-choice and .env are ignored; .env is unstaged."
