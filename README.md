# 🤖 GitOps Homelab

My overkill kubernetes homelab. 

## 🧰 Hardware

### 🗄️ **Dell EMC PowerEdge C6400** : Power hungry blade server chassis
- 4 x C6420 : server blades
- 2x Intel® Xeon® Gold 6132 Processor
- 256gb DDR4 Memory
- 10 gigabit RJ45 NIC

### 🖥️ **Intel NUC9VXQNX**: Mini PC/Server

- Intel® Xeon® Intel Xeon E-2286M Processor
- 64GB DDR4 Memory
- 10 gigabit SFP+ card

## 💡Core Technologies

- **[Proxmox](https://www.proxmox.com/)**: Hypervisor for virtualized cluster nodes
- **[Talos Linux](https://www.talos.dev/)**: Modern OS for running Kubernetes: secure, immutable, and minimal
- **[Terraform/OpenTofu](https://opentofu.org/)**: Deploys Talos virtual machines to Proxmox. Also manages authentik.
- **[Kubernetes](https://kubernetes.io/)**: Orchestrates containerized applications across a cluster of nodes.
- **[FluxCD](https://fluxcd.io/)**: Manages GitOps for continuous delivery.
- **[SOPS](https://github.com/mozilla/sops)**: Encrypts secrets for secure storage and management.
- **[Kustomize](https://kustomize.io/)**: Customizes Kubernetes resource configurations.

### 🛠️ Cluster Infrastructure
- **[Cert-Manager](https://cert-manager.io/)**: Manages TLS certificates for the cluster.
- **[MetalLB](https://metallb.universe.tf/)**: Provides load balancing for services.
- **[ExternalDNS](https://github.com/kubernetes-sigs/external-dns)**: Updates DNS records based on Kubernetes resources.
- **[Node Feature Discovery](https://github.com/kubernetes-sigs/node-feature-discovery)**: Detects hardware features available on nodes.
- **[Snapshot Controller](https://github.com/kubernetes-csi/external-snapshotter)**: Manages volume snapshots for persistent storage.
- **[Intel GPU Plugin](https://github.com/intel/intel-device-plugins-for-kubernetes)**: Manages Intel GPU resources for workloads.
- **[Democratic CSI](https://github.com/democratic-csi/democratic-csi)**: Provides CSI drivers for storage management.
- **[Ingress NGINX](https://kubernetes.github.io/ingress-nginx/)**: Manages ingress traffic to the cluster.
- **[LGTM Monitoring Stack](https://github.com/grafana/loki)**: Includes Prometheus and Grafana for monitoring and visualization.
- **[Tofu Controller](https://github.com/opentofu/controller)**: Manages Tofu-based applications in flux


## 📲 Applications Running in the Cluster

### 🗂️ Databases
- **[Cloudnative PG](https://cloudnative-pg.io/)**: A PostgreSQL operator for managing PostgreSQL clusters.

### 📺 Media Apps
- **[Jellyfin](https://jellyfin.org/)**: A media server for streaming and organizing media.


### 🪪 Identity Management
- **[Authentik](https://goauthentik.io/)**: An identity provider for authentication and authorization.
