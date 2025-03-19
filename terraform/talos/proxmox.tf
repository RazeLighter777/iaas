# Add module variables at the top
variable "nodes" {
  description = "Node configuration for control planes and workers"
  type = object({
    controlplanes = map(object({
      name         = string
      install_disk = string
      ip           = string
      vm = object({
        cores           = number
        memory          = number
        disk_size       = number
        pci_passthrough = bool
        pci_device      = string
      })
    }))
    workers = map(object({
      name         = string
      install_disk = string
      ip           = string
      vm = object({
        cores           = number
        memory          = number
        disk_size       = number
        pci_passthrough = bool
        pci_device      = string
      })
    }))
  })
  default = {
    controlplanes = {
      "cp0" = {
        name         = "node1"
        install_disk = "/dev/vda"
        ip           = "192.168.1.8"
        vm = {
          cores           = 8
          memory          = 16000
          disk_size       = 128
          pci_passthrough = false
          pci_device      = null
        }
      },
      "cp1" = {
        name         = "node1"
        install_disk = "/dev/vda"
        ip           = "192.168.1.6"
        vm = {
          cores           = 8
          memory          = 16000
          disk_size       = 128
          pci_passthrough = false
          pci_device      = null
        }
      },
      "cp2" = {
        name         = "node1"
        install_disk = "/dev/vda"
        ip           = "192.168.1.7"
        vm = {
          cores           = 8
          memory          = 16000
          disk_size       = 128
          pci_passthrough = false
          pci_device      = null
        }
      }
    }
    workers = {
      "w1" = {
        name         = "nuc"
        install_disk = "/dev/vda"
        ip           = "192.168.1.9"
        vm = {
          cores           = 8
          memory          = 32000
          disk_size       = 200
          pci_passthrough = true
          pci_device      = "igpu"
        }
      }
    }
  }
}

locals {
  talos = {
    version = "v1.9.4"
    url     = "https://factory.talos.dev/image/96fa7f1f7b45c3234a4dbe767002b7dbac60458bc555398c13396ce3971a5072/v1.9.4/nocloud-amd64.iso"
  }

  network = {
    default_gateway = "192.168.1.254"
    default_dns     = "192.168.1.254"
    subnet          = "/24"
  }

  cluster = {
    name     = "cluster"
    endpoint = "https://192.168.1.8:6443"
  }

  # Use the variable instead of hardcoded values
  unique_nodes = toset(flatten(distinct([for nodes in [var.nodes.controlplanes, var.nodes.workers] : values(nodes)[*].name])))

  # Create a map of all nodes with their IPs for easier reference
  all_nodes = merge(
    { for k, v in var.nodes.controlplanes : k => v },
    { for k, v in var.nodes.workers : k => v }
  )

  # Extract control plane IPs for endpoints
  controlplane_ips = [for node in var.nodes.controlplanes : node.ip]
}

# Download Talos image for each node
resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each     = local.unique_nodes
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key

  file_name = "talos-${local.talos.version}-nocloud-${each.key}.amd64.iso"
  url       = local.talos.url
  overwrite = false
}

# Create VMs for all nodes
resource "proxmox_virtual_environment_vm" "talos_nodes" {
  for_each    = local.all_nodes
  name        = "talos-${local.talos.version}-${each.value.name}"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = each.value.name
  on_boot     = true
  boot_order  = ["virtio1", "ide0"]

  cpu {
    cores = each.value.vm.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.vm.memory
    floating  = each.value.vm.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  # Install CD
  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.name].id
    interface = "ide0"
  }

  # Root disk
  disk {
    datastore_id = "local-lvm"
    interface    = "virtio1"
    file_format  = "raw"
    size         = each.value.vm.disk_size
  }

  # PCI Passthrough configuration for Intel eGPU (only for nuc node)
  dynamic "hostpci" {
    for_each = each.value.vm.pci_passthrough ? [1] : []
    content {
      device  = "hostpci0"
      mapping = each.value.vm.pci_device
      rombar  = true
      pcie    = true
      xvga    = true
    }
  }
  # add efi disk for UEFI boot
  efi_disk {
    type = "4m"
  }

  # vmware compatible display
  vga {
    type = each.value.vm.pci_passthrough ? "none" : "vmware"
  }

  # Intel GPU requires machine to use OVMF/UEFI
  machine = "q35"
  bios    = "ovmf"


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X
  }

  initialization {
    dns {
      servers = [local.network.default_dns]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ip}${local.network.subnet}"
        gateway = local.network.default_gateway
      }
    }
  }
}

# Talos configuration
resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = local.cluster.name
  cluster_endpoint = local.cluster.endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.cluster.name
  cluster_endpoint = local.cluster.endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.controlplane_ips
}

# Common function for both controlplane and worker configuration
resource "talos_machine_configuration_apply" "nodes" {
  depends_on           = [proxmox_virtual_environment_vm.talos_nodes]
  client_configuration = talos_machine_secrets.this.client_configuration
  
  for_each = {
    for k, v in local.all_nodes : k => v
  }
  
  machine_configuration_input = contains(keys(var.nodes.controlplanes), each.key) ? data.talos_machine_configuration.controlplane.machine_configuration : data.talos_machine_configuration.worker.machine_configuration
    
  node = each.value.ip
  
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname        = each.key
      install_disk    = each.value.install_disk
      install_ip      = each.value.ip
      install_cidr    = local.network.subnet
      install_gateway = local.network.default_gateway
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.nodes]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(var.nodes.controlplanes)[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(var.nodes.controlplanes)[0]
}
