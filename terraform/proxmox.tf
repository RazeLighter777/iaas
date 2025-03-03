locals {
  talos = {
    version = "v1.9.4"
    url     = "https://factory.talos.dev/image/96fa7f1f7b45c3234a4dbe767002b7dbac60458bc555398c13396ce3971a5072/v1.9.4/nocloud-amd64.iso"
  }

  network = {
    default_gateway = "192.168.1.254"
    default_dns     = "192.168.1.254"
    subnet          = "/24"
    domain          = "prizrak.me"
  }

  cluster = {
    name     = "prizrakcluster"
    endpoint = "https://192.168.1.8:6443"
  }

  # Unified node configuration
  nodes = {
    controlplanes = {
      "192.168.1.8" = {
        name         = "node1"
        install_disk = "/dev/vda"
        hostname     = "cp0"
        vm = {
          cores    = 8
          memory   = 16000
          disk_size = 128
          # GPU passthrough config
          pci_passthrough = false
          pci_device      = null
        }
      },
      "192.168.1.6" = {
        name         = "node1"
        install_disk = "/dev/vda"
        hostname     = "cp1"
        vm = {
          cores    = 8
          memory   = 16000
          disk_size = 128
          # GPU passthrough config
          pci_passthrough = false
          pci_device      = null
        }
      },
      "192.168.1.7" = {
        name         = "node1"
        install_disk = "/dev/vda"
        hostname     = "cp2"
        vm = {
          cores    = 8
          memory   = 16000
          disk_size = 128
          # GPU passthrough config
          pci_passthrough = false
          pci_device      = null
        }
      }
    }
    workers = {
      "192.168.1.9" = {
        name         = "nuc"
        install_disk = "/dev/vda"
        hostname     = "w1"
        vm = {
          cores    = 8
          memory   = 32000
          disk_size = 200
          # No GPU passthrough for this node
          # pci_passthrough = true
          # pci_device      = "igpu"  # Intel eGPU mapping
          pci_passthrough = false
          pci_device      = null
        }
      }
    }
  }
}

# Download Talos image for each node
resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each     = merge(local.nodes.controlplanes, local.nodes.workers)
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.value.name

  file_name = "talos-${local.talos.version}-nocloud-${each.value.hostname}.amd64.iso"
  url       = local.talos.url
  overwrite = false
}

# Create VMs for all nodes
resource "proxmox_virtual_environment_vm" "talos_nodes" {
  for_each    = merge(local.nodes.controlplanes, local.nodes.workers)
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
    file_id   = proxmox_virtual_environment_download_file.talos_nocloud_image[each.key].id
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
      device = "hostpci0"
      mapping  = each.value.vm.pci_device
      rombar  = true
      pcie    = true
      xvga   = true
    }
  }
  # add efi disk for UEFI boot
  efi_disk {
    type = "4m"
  }

  # vmware compatible display
  vga {
    type = "vmware"
  }

  # Intel GPU requires machine to use OVMF/UEFI
  machine = "q35"
  bios = "ovmf"


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X
  }

  initialization {
    dns {
      domain  = local.network.domain
      servers = [local.network.default_dns]
    }
    ip_config {
      ipv4 {
        address = "${each.key}${local.network.subnet}"
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
  endpoints            = keys(local.nodes.controlplanes)
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_nodes]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = local.nodes.controlplanes
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname != null ? each.value.hostname : format("%s-cp-%s", local.cluster.name, index(keys(local.nodes.controlplanes), each.key))
      install_disk = each.value.install_disk
      install_ip   = each.key
      install_cidr = local.network.subnet
      install_gateway = local.network.default_gateway
      
    }),
    file("${path.module}/files/cp-scheduling.yaml"),
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_nodes]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = local.nodes.workers
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/install-disk-and-hostname.yaml.tmpl", {
      hostname     = each.value.hostname != null ? each.value.hostname : format("%s-worker-%s", local.cluster.name, index(keys(local.nodes.workers), each.key))
      install_disk = each.value.install_disk
      install_ip   = each.key
      install_cidr = local.network.subnet
      install_gateway = local.network.default_gateway
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on           = [talos_machine_configuration_apply.controlplane]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(local.nodes.controlplanes)[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = keys(local.nodes.controlplanes)[0]
}