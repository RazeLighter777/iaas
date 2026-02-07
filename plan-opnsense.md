## Plan: OPNsense Terraform module

Create a new Terraform module under terraform/opnsense that uses the OPNsense provider, sources credentials from Vault, and lays out resource blocks aligned to a bulk-import workflow. We’ll mirror existing provider/variable patterns from other Terraform folders and align Vault secret usage with the existing Vault module so secrets stay centralized.

### Steps 3–6 steps, 5–20 words each

1. Review Vault secret patterns in terraform/vault/main.tf and provider setup in terraform/vault/providers.tf.
2. Scaffold terraform/opnsense with required_providers, provider config, and variables patterned after terraform/servarr/providers.tf and terraform/authentik/providers.tf.
3. Add Vault data sources/inputs in terraform/opnsense to fetch api_key, api_secret, opnsense_router_ip, following Vault secret conventions.
4. Draft OPNsense resource blocks and an import mapping plan for bulk import, aligning to the provider docs and your existing config.
5. Define module inputs/outputs and document usage, mirroring the variables.tf style in terraform/authentik/variables.tf.

### Notes

Since the OS is NixOS, I'll need to install the Terraform and other packages manually with nix-shell -p <package-name>,
making sure to specify NIXPKGS_ALLOW_UNFREE=1 for terraform/providers that may be unfree.

### Further Considerations 1–3, 5–25 words each

1. Which bulk import approach do you prefer: manual terraform import, terraformer, or provider-specific import tooling?

I'll give terraformer a try.

2. Should the OPNsense module manage only firewall objects, or also services/users/certs?

I think the only objects the provider supports that I'm using are firewall, interfaces, routes, and wireguard. Query
it to find out. I don't need to manage other services/users/certs

3. Do you want the Vault secret to remain authored in Vault Terraform (like terraform/vault/main.tf) or managed externally?

Let's keep anything needed that should be secret in our vault, and have this module pull from there as needed for api
keys, ssh keys, or anything else sensitive. Subnets, ip ranges, and firewall rules are not sensitive, only things which
being public would be detrimental.
