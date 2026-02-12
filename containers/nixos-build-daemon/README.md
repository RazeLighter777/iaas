# nixos-build-daemon

## Environment variables

None.

## Volume mounts

- `/nix` (required): Shared Nix store and runtime state.
- `/nix/var/nix/daemon-socket` (optional but recommended): Nix daemon UNIX socket for clients or sidecar containers.

## Notes

- Sandboxed builds are configured to run in `/tmp/nix-build` (not `/build`) to avoid permission issues on Kubernetes-mounted volumes.
- `/etc/nix/nix.conf` sets `sandbox = true`, `build-users-group = nixbld`, `build-dir = /tmp/nix-build`, and `sandbox-build-dir = /tmp/nix-build`.
SSH keys and configuration are managed by the SSH gateway container and are not mounted into this image.
