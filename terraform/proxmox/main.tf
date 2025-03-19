module "k8s_cluster" {
  source = "./cluster"
  
  nodes = {
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
    },
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

  network = {
    default_gateway = "192.168.1.254"
    default_dns     = "192.168.1.254"
    subnet          = "/24"
  }

  cluster = {
    name     = "cluster"
    endpoint = "https://192.168.1.8:6443"
  }

  talos = {
    version = "v1.9.4"
    url     = "https://factory.talos.dev/image/96fa7f1f7b45c3234a4dbe767002b7dbac60458bc555398c13396ce3971a5072/v1.9.4/nocloud-amd64.iso"
  }
}

# Access outputs from the module
output "kubeconfig" {
  description = "Kubeconfig for the Talos cluster"
  value       = module.k8s_cluster.kubeconfig
  sensitive   = true
}

output "controlplane_ips" {
  description = "IPs of the control plane nodes"
  value       = module.k8s_cluster.controlplane_ips
}

output "worker_ips" {
  description = "IPs of the worker nodes"
  value       = module.k8s_cluster.worker_ips
}

output "talosconfig" {
  description = "Talos client configuration for talosctl"
  value       = module.k8s_cluster.talos_client_configuration
  sensitive   = true
}