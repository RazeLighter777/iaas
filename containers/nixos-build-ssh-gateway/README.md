# nixos-build-ssh-gateway

## Environment variables

None.

## Volume mounts

- `/nix` (required): Shared Nix store.
- `/ssh` (required): SSH runtime state.

### Expected files under `/ssh`

Provided via the `/ssh` volume:

- `authorized_keys` (required)
- `ssh_host_rsa_key` and `ssh_host_ed25519_key` (required)

`sshd_config` is baked into the image.
