#!/bin/sh
set -eu

mkdir -p /etc/nix /nix/var/nix/daemon-socket /nix/var/nix/builds
chown 0:0 /nix/var/nix/builds
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

is_uint() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
    *) return 0 ;;
  esac
}

if [ -n "${NIX_STORE_MIN_FREE:-}" ] && [ -n "${NIX_STORE_MAX_FREE:-}" ]; then
  {
    printf '%s\n' "min-free = ${NIX_STORE_MIN_FREE}"
    printf '%s\n' "max-free = ${NIX_STORE_MAX_FREE}"
  } >> /etc/nix/nix.conf
elif [ -n "${NIX_STORE_MIN_FREE:-}" ] || [ -n "${NIX_STORE_MAX_FREE:-}" ]; then
  echo "start-nix-daemon: both NIX_STORE_MIN_FREE and NIX_STORE_MAX_FREE are required; skipping min/max free config"
else
  min_pct="${NIX_STORE_MIN_FREE_PERCENT:-10}"
  max_pct="${NIX_STORE_MAX_FREE_PERCENT:-20}"
  if ! is_uint "${min_pct}" || ! is_uint "${max_pct}"; then
    echo "start-nix-daemon: invalid NIX_STORE_MIN_FREE_PERCENT/NIX_STORE_MAX_FREE_PERCENT; using defaults 10/20"
    min_pct=10
    max_pct=20
  fi

  if [ "${max_pct}" -le "${min_pct}" ]; then
    echo "start-nix-daemon: NIX_STORE_MAX_FREE_PERCENT must be greater than NIX_STORE_MIN_FREE_PERCENT; using defaults 10/20"
    min_pct=10
    max_pct=20
  fi

  nix_total_blocks=""
  while IFS=' ' read -r filesystem blocks used available capacity mounted_on; do
    if [ "${filesystem}" = "Filesystem" ]; then
      continue
    fi
    nix_total_blocks="${blocks}"
    break
  done <<EOF
$(df -Pk /nix)
EOF

  if is_uint "${nix_total_blocks}" && [ "${nix_total_blocks}" -gt 0 ]; then
    nix_total_bytes=$((nix_total_blocks * 1024))
    min_free_bytes=$((nix_total_bytes * min_pct / 100))
    max_free_bytes=$((nix_total_bytes * max_pct / 100))

    {
      printf '%s\n' "min-free = ${min_free_bytes}"
      printf '%s\n' "max-free = ${max_free_bytes}"
    } >> /etc/nix/nix.conf
  else
    echo "start-nix-daemon: failed to determine /nix volume size, skipping min/max free config"
  fi
fi

if [ -n "${NIX_KEEP_DERIVATIONS:-}" ]; then
  printf '%s\n' "keep-derivations = ${NIX_KEEP_DERIVATIONS}" >> /etc/nix/nix.conf
fi

if [ -n "${NIX_KEEP_OUTPUTS:-}" ]; then
  printf '%s\n' "keep-outputs = ${NIX_KEEP_OUTPUTS}" >> /etc/nix/nix.conf
fi

exec nix-daemon --daemon
