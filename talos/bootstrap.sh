#!/bin/bash
terraform output kubeconfig  | grep -v EOT > ~/.kube/config
terraform output talosconfig  | grep -v EOT > ~/.talos/config
helm install     cilium     cilium/cilium     --version 1.15.6     --namespace kube-system     --set ipam.mode=kubernetes     --set kubeProxyReplacement=true     --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"     --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"     --set cgroup.autoMount.enabled=false     --set cgroup.hostRoot=/sys/fs/cgroup     --set k8sServiceHost=localhost     --set k8sServicePort=7445
flux bootstrap git --url=ssh://git@github.com/razelighter777/iaas.git --path=cluster/bootstrap --private-key-file=/home/justin/.ssh/id_ed25519
cat ~/sops-key.yaml | kubectl create secret generic sops-age --namespace=flux-system --from-file=age.agekey=/dev/stdin