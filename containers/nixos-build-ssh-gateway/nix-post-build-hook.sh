#!/bin/sh
set -eu

if [ -z "${NIX_S3_BUCKET:-}" ] || [ -z "${NIX_S3_ENDPOINT:-}" ] || [ -z "${NIX_S3_REGION:-}" ]; then
  echo "nix-post-build-hook: S3 cache settings missing, skipping upload"
  exit 0
fi

if [ -z "${NIX_CACHE_PRIVATE_KEY_FILE:-}" ] || [ ! -s "${NIX_CACHE_PRIVATE_KEY_FILE}" ]; then
  echo "nix-post-build-hook: signing key missing at ${NIX_CACHE_PRIVATE_KEY_FILE:-<unset>}, skipping"
  exit 0
fi

paths="$*"
if [ -z "${paths}" ] && [ -n "${OUT_PATHS:-}" ]; then
  paths="${OUT_PATHS}"
fi

if [ -z "${paths}" ]; then
  echo "nix-post-build-hook: no output paths provided"
  exit 0
fi

nix sign-paths --key-file "${NIX_CACHE_PRIVATE_KEY_FILE}" ${paths}

nix copy --to "s3://${NIX_S3_BUCKET}?endpoint=${NIX_S3_ENDPOINT}&region=${NIX_S3_REGION}&scheme=${NIX_S3_SCHEME:-https}&profile=${AWS_PROFILE:-default}" ${paths}
