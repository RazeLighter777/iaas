#!/bin/bash
flux bootstrap git --url=ssh://git@github.com/razelighter777/iaas.git --path=cluster/bootstrap --private-key-file=$HOME/.ssh/id_ed25519
sops -d ./terraform/vault/vault-creds.sops.yaml | kubectl apply -f -