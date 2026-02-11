# nixos-build-nix-serve

## Environment variables

- `NIX_SECRET_KEY_FILE` (required for signing): Path to the private signing key used by `nix-serve`.

## Volume mounts

- `/nix` (required): Shared Nix store from the build daemon.
- `/cache-keys` (required when signing): Mount the signing key file here.

### Recommended key mount

Mount the signing key file and set `NIX_SECRET_KEY_FILE` to its path, for example:

- `/cache-keys/nix-cache-secret`
