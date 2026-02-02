# 🤖 GitOps Homelab

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/RazeLighter777/iaas/taskfile-tests-workflow.yaml)

My overkill kubernetes homelab. 


## 💡Core Technologies

- **[Talos Linux](https://www.talos.dev/)**: Modern OS for running Kubernetes: secure, immutable, and minimal
- **[Terraform/OpenTofu](https://opentofu.org/)**: Manages configuration for some services.
- **[Kubernetes](https://kubernetes.io/)**: Orchestrates containerized applications across a cluster of nodes.
- **[FluxCD](https://fluxcd.io/)**: Manages GitOps for continuous delivery.
- **[External Secrets](https://github.com/external-secrets/external-secrets)**: Manages secrets from external sources.
- **[Kustomize](https://kustomize.io/)**: Customizes Kubernetes resource configurations.

### 🛠️ Cluster Infrastructure
- **[Cert-Manager](https://cert-manager.io/)**: Manages TLS certificates for the cluster.
- **[Cilium](https://cilim.io/)**: Provides eBPF-based cloud native networking for kubernetes
- **[ExternalDNS](https://github.com/kubernetes-sigs/external-dns)**: Updates DNS records based on Kubernetes resources.
- **[Node Feature Discovery](https://github.com/kubernetes-sigs/node-feature-discovery)**: Detects hardware features available on nodes.
- **[Intel GPU Plugin](https://github.com/intel/intel-device-plugins-for-kubernetes)**: Manages Intel GPU resources for workloads.
- **[Longhorn](https://longhorn.io/)**: Provides distributed block storage for Kubernetes.
- **[Traefik](https://traefik.io/)**: Ingress controller with Gateway API support for managing HTTP/HTTPS traffic to the cluster.
- **[Cloudflared](https://github.com/cloudflare/cloudflared)**: Cloudflare tunnel for secure external access.
- **[LGTM Monitoring Stack](https://github.com/grafana/loki)**: Includes Prometheus and Grafana for monitoring and visualization.
- **[HashiCorp Vault](https://www.vaultproject.io/)**: Manages secrets and encryption keys.
- **[MinIO](https://min.io/)**: An open-source object storage system.

## 📲 Applications Running in the Cluster

### Games
- **[SillyTavern](https://github.com/sillytavern/SillyTavern)**: A chatbot for role-playing games.
- **[Minecraft](https://www.minecraft.net/)**: A popular sandbox game.

### 🗂️ Databases
- **[Cloudnative PG](https://cloudnative-pg.io/)**: A PostgreSQL operator for managing PostgreSQL clusters.
- **[Redis](https://redis.io)**: Low latency key-value store.
- **[EMQX](https://www.emqx.com/)**: An open-source MQTT broker.
## 🏠 Smart Home 
- **[Home Assistant](https://home-assistant.io/)** : Smart home automation platform
- **[Frigate](https://frigate.video)**: Open source security camera NVR with object detection. 
- **[Neolink](https://github.com/QuantumEntangledAndy/neolink)**: Lets you connect reolink proprietary cameras to frigate.

### 📺 Media Apps
- **[Jellyfin](https://jellyfin.org/)**: A media server for streaming and organizing media.


### 🪪 Identity Management
- **[Authentik](https://goauthentik.io/)**: An identity provider for authentication and authorization.

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
