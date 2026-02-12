# nixos-build-daemon

## Environment variables

None.

## Volume mounts

- `/nix` (required): Shared Nix store and runtime state.
- `/nix/var/nix/daemon-socket` (optional but recommended): Nix daemon UNIX socket for clients or sidecar containers.
- `/nix/var/nix/builds` (recommended tmpfs mount): Nix sandbox build directory; expected ownership `root:root` and mode `0755`.

## Notes

- Sandboxed builds are configured to run in `/nix/var/nix/builds`.
- `/etc/nix/nix.conf` sets `sandbox = true`, `build-users-group = nixbld`, `build-dir = /nix/var/nix/builds`, and `sandbox-build-dir = /nix/var/nix/builds`.
  SSH keys and configuration are managed by the SSH gateway container and are not mounted into this image.
