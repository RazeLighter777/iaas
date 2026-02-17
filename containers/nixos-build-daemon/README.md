# nixos-build-daemon

## Environment variables

- `NIX_CACHE_PRIVATE_KEY_FILE` (optional): Path to binary cache private key used for `nix sign-paths`.
- `NIX_CACHE_PUBLIC_KEY` (optional): Public key added to `trusted-public-keys`.
- `NIX_S3_BUCKET` (required for upload): S3 bucket for binary cache artifacts.
- `NIX_S3_ENDPOINT` (required for upload): S3 endpoint host.
- `NIX_S3_REGION` (required for upload): S3 region.
- `NIX_S3_SCHEME` (optional): S3 URL scheme (`https` default).
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (required for upload): S3 credentials.
- `NIX_STORE_MIN_FREE` / `NIX_STORE_MAX_FREE` (optional, bytes): Explicitly set `min-free` / `max-free` in `nix.conf`.
- `NIX_STORE_MIN_FREE_PERCENT` / `NIX_STORE_MAX_FREE_PERCENT` (optional, integers): If byte values above are not set, compute `min-free` / `max-free` as a percentage of `/nix` total size. Defaults are `10` and `20`.
- `NIX_KEEP_DERIVATIONS` (optional): Overrides `keep-derivations` in `nix.conf`.
- `NIX_KEEP_OUTPUTS` (optional): Overrides `keep-outputs` in `nix.conf`.

## Volume mounts

- `/nix` (required): Shared Nix store and runtime state.
- `/nix/var/nix/daemon-socket` (optional but recommended): Nix daemon UNIX socket for clients or sidecar containers.
- `/nix/var/nix/builds` (recommended tmpfs mount): Nix sandbox build directory; expected ownership `root:root` and mode `0755`.
- `/cache-keys` (optional): Mount location for cache signing key material.

## Notes

- Startup writes `/etc/nix/nix.conf` dynamically and keeps sandboxing enabled.
- Successful outputs are signed with `nix sign-paths` and uploaded using `nix copy --to s3://...` via post-build hook `/usr/local/bin/nix-post-build-hook.sh`.
  SSH keys and configuration are managed by the SSH gateway container and are not mounted into this image.
- Prefer GC via `min-free`/`max-free` (or periodic `nix-collect-garbage`) instead of deleting outputs directly in `post-build-hook`; deleting in-hook can race remote copy behavior.
- If `NIX_STORE_MIN_FREE`/`NIX_STORE_MAX_FREE` are unset, startup now auto-sizes these values from the `/nix` filesystem capacity.
