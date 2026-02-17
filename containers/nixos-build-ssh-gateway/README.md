# nixos-build-ssh-gateway

## Environment variables

- `NIX_CACHE_PRIVATE_KEY_FILE` (optional): Path to binary cache private key used for `nix sign-paths`.
- `NIX_S3_BUCKET` / `NIX_S3_ENDPOINT` / `NIX_S3_REGION` (optional): S3 cache target used by post-build hook.
- `NIX_S3_SCHEME` (optional): S3 URL scheme (`https` default).
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (optional): S3 credentials used by `nix copy`.

The image includes `/usr/local/bin/nix-post-build-hook.sh` so environments that configure
`post-build-hook = /usr/local/bin/nix-post-build-hook.sh` do not fail if hook execution occurs
through the SSH gateway process.

## Volume mounts

- `/nix` (required): Shared Nix store.
- `/ssh` (required): SSH runtime state.

### Expected files under `/ssh`

Provided via the `/ssh` volume:

- `authorized_keys` (required)
- `ssh_host_rsa_key` and `ssh_host_ed25519_key` (required)

`sshd_config` is baked into the image.
