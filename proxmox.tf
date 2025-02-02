locals {
  talos = {
    version = "v1.9.3"
    url     = "https://factory.talos.dev/image/dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586/v1.9.3/nocloud-amd64.iso"
  }

  default_gateway = "192.168.1.254"
  default_dns = "192.168.1.1"
  subnet = "/24"
  cluster_name = "prizrakcluster"
  cluster_endpoint = "https://192.168.1.8:6443"
  nodes = [
      {
        name = "hpbw243"
        ip = "192.168.1.8"
        config = "controlplane"
      }, 
      {
        name = "hpbs243"
        ip = "192.168.1.9"
        config = "controlplane"
      },  
      {
        name = "hpbt243"
        ip = "192.168.1.11"
        config = "controlplane"
      },  
      {
        name = "hpbv243"
        ip = "192.168.1.12"
        config = "worker"
      }
    ]
}

resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each    = { for node in local.nodes : node.name => node }
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.value.name

  file_name = "talos-${local.talos.version}-nocloud-amd64.iso"
  url       = local.talos.url
  overwrite = false
}

# Create a VM for each node
resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  for_each    = { for node in local.nodes : node.name => node }
  name        = "talos-${local.talos.version}-${each.value.name}"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = each.value.name
  on_boot     = true

  cpu {
    cores = 14
    type = "host"
  }

  memory {
    dedicated = 16000
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  # install cd
  cdrom {
    file_id = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.name].id
    enabled = true
  }

  # root disk
  disk {
    datastore_id = "iscsi_vg_proxmox"
    interface    = "virtio1"
    file_format  = "raw"
    size         = 200
  }


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    dns {
      domain = "prizrak.me"
      servers = [local.default_dns]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}${local.subnet}"
        gateway = local.default_gateway

      }
    }
  }
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    workers = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
  })
  default = {
    controlplanes = {
      "192.168.1.8" = {
        install_disk = "/dev/vda"
      },
      "192.168.1.9" = {
        install_disk = "/dev/vda"
      },
      "192.168.1.11" = {
        install_disk = "/dev/vda"
      }
    }
    workers = {
      "192.168.1.12" = {
        install_disk = "/dev/vda"
        hostname     = "worker-1"
      },
    }
  }
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [proxmox_virtual_environment_vm.talos_cp_01]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = var.node_data.controlplanes
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-cp-%s", local.cluster_name, index(keys(var.node_data.controlplanes), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
    }),
    file("${path.module}/files/cp-scheduling.yaml"),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [proxmox_virtual_environment_vm.talos_cp_01]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = var.node_data.workers
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-worker-%s", local.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}