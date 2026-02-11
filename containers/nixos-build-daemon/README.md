# nixos-build-daemon

## Environment variables

None.

## Volume mounts

- `/nix` (required): Shared Nix store and runtime state.
- `/nix/var/nix/daemon-socket` (optional but recommended): Nix daemon UNIX socket for clients or sidecar containers.

## Notes

SSH keys and configuration are managed by the SSH gateway container and are not mounted into this image.
