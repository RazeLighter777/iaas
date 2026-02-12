#!/bin/sh
set -eu

mkdir -p /etc/nix /nix/var/nix/daemon-socket /nix/var/nix/builds
chown root:root /nix/var/nix/builds
chmod 0755 /nix/var/nix/builds

mkdir -p "${HOME:-/root}/.aws"
if [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  cat >"${AWS_SHARED_CREDENTIALS_FILE:-${HOME:-/root}/.aws/credentials}" <<EOF
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF

  region="${AWS_REGION:-${NIX_S3_REGION:-}}"
  if [ -n "${region}" ]; then
    cat >"${AWS_CONFIG_FILE:-${HOME:-/root}/.aws/config}" <<EOF
[default]
region = ${region}
EOF
  fi

  chmod 0600 "${AWS_SHARED_CREDENTIALS_FILE:-${HOME:-/root}/.aws/credentials}"
  if [ -f "${AWS_CONFIG_FILE:-${HOME:-/root}/.aws/config}" ]; then
    chmod 0600 "${AWS_CONFIG_FILE:-${HOME:-/root}/.aws/config}"
  fi
fi

trusted_keys="cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
if [ -n "${NIX_CACHE_PUBLIC_KEY:-}" ]; then
  trusted_keys="${trusted_keys} ${NIX_CACHE_PUBLIC_KEY}"
fi

substituters="https://cache.nixos.org"
if [ -n "${NIX_S3_BUCKET:-}" ] && [ -n "${NIX_S3_ENDPOINT:-}" ] && [ -n "${NIX_S3_REGION:-}" ]; then
  substituters="${substituters} s3://${NIX_S3_BUCKET}?endpoint=${NIX_S3_ENDPOINT}&region=${NIX_S3_REGION}&scheme=${NIX_S3_SCHEME:-https}&profile=${AWS_PROFILE:-default}"
fi

cat >/etc/nix/nix.conf <<EOF
experimental-features = nix-command flakes daemon-trust-override
sandbox = true
build-users-group = nixbld
build-dir = /nix/var/nix/builds
sandbox-build-dir = /nix/var/nix/builds
builders-use-substitutes = true
substituters = ${substituters}
trusted-substituters = ${substituters}
trusted-public-keys = ${trusted_keys}
post-build-hook = /usr/local/bin/nix-post-build-hook.sh
EOF

if [ -n "${NIX_CACHE_PRIVATE_KEY_FILE:-}" ] && [ -s "${NIX_CACHE_PRIVATE_KEY_FILE}" ]; then
  printf '%s\n' "secret-key-files = ${NIX_CACHE_PRIVATE_KEY_FILE}" >> /etc/nix/nix.conf
fi

exec nix-daemon --daemon
