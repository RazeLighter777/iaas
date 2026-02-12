# nixos-build-daemon

## Environment variables

- `NIX_CACHE_PRIVATE_KEY_FILE` (optional): Path to binary cache private key used for `nix sign-paths`.
- `NIX_CACHE_PUBLIC_KEY` (optional): Public key added to `trusted-public-keys`.
- `NIX_S3_BUCKET` (required for upload): S3 bucket for binary cache artifacts.
- `NIX_S3_ENDPOINT` (required for upload): S3 endpoint host.
- `NIX_S3_REGION` (required for upload): S3 region.
- `NIX_S3_SCHEME` (optional): S3 URL scheme (`https` default).
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (required for upload): S3 credentials.

## Volume mounts

- `/nix` (required): Shared Nix store and runtime state.
- `/nix/var/nix/daemon-socket` (optional but recommended): Nix daemon UNIX socket for clients or sidecar containers.
- `/nix/var/nix/builds` (recommended tmpfs mount): Nix sandbox build directory; expected ownership `root:root` and mode `0755`.
- `/cache-keys` (optional): Mount location for cache signing key material.

## Notes

- Startup writes `/etc/nix/nix.conf` dynamically and keeps sandboxing enabled.
- Successful outputs are signed with `nix sign-paths` and uploaded using `nix copy --to s3://...` via post-build hook `/usr/local/bin/nix-post-build-hook.sh`.
  SSH keys and configuration are managed by the SSH gateway container and are not mounted into this image.
