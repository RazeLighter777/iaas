# 🤖 GitOps Homelab

My overkill kubernetes homelab. 

## 🧰 Hardware

### 🗄️ **Dell EMC PowerEdge C6400** : Power hungry blade server chassis
- 4 x C6420 : server blades
- Intel® Xeon® Gold 6132 Processor
- 64GB DDR4 Memory
- 10 gigabit RJ45 NIC

### 🖥️ **Intel NUC9VXQNX**: Mini PC/Server

- Intel® Xeon® Intel Xeon E-2286M Processor
- 64GB DDR4 Memory
- 10 gigabit SFP+ card

## 💡Core Technologies

- **Proxmox**: Hypervisor for virtualized cluster nodes
- **Talos Linux**: Modern OS for running Kubernetes: secure, immutable, and minimal
- **Terraform/OpenTofu**: Deploys Talos virtual machines to Proxmox. Also manages authentik.
- **Kubernetes**: Orchestrates containerized applications across a cluster of nodes.
- **FluxCD**: Manages GitOps for continuous delivery.
- **SOPS**: Encrypts secrets for secure storage and management.
- **Kustomize**: Customizes Kubernetes resource configurations.

### 🛠️ Cluster Infrastructure
- **Cert-Manager**: Manages TLS certificates for the cluster.
- **MetalLB**: Provides load balancing for services.
- **ExternalDNS**: Updates DNS records based on Kubernetes resources.
- **Node Feature Discovery**: Detects hardware features available on nodes.
- **Snapshot Controller**: Manages volume snapshots for persistent storage.
- **Intel GPU Plugin**: Manages Intel GPU resources for workloads.
- **Democratic CSI**: Provides CSI drivers for storage management.
- **Ingress NGINX**: Manages ingress traffic to the cluster.
- **LGTM Monitoring Stack**: Includes Prometheus and Grafana for monitoring and visualization.
- **Tofu Controller**: Manages Tofu-based applications in flux


## 📲 Applications Running in the Cluster

### 🗂️ Databases
- **Cloudnative PG**: A PostgreSQL operator for managing PostgreSQL clusters.

### 📺 Media Apps
- **Prowlarr**: A Torznab API proxy for Sonarr, Radarr, and Lidarr.
- **Radarr**: A movie collection manager for Usenet and BitTorrent users.
- **Sonarr**: A PVR for Usenet and BitTorrent users to manage TV series.
- **Jellyfin**: A media server for streaming and organizing media.
- **qBittorrent**: An open-source BitTorrent client.


### 🪪 Identity Management
- **Authentik**: An identity provider for authentication and authorization.