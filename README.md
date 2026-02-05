# 🤖 GitOps Homelab

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/RazeLighter777/iaas/taskfile-tests-workflow.yaml)

This homelab is the result of learning Kubernetes and infrastructure-as-code principles from scratch. It represents the culmination of my homelabbing efforts so far.

For many years, I was a Docker Compose diehard. I eventually migrated away from it when the number of services and the level of integration between them became unwieldy. My Compose deployments were fragile and broke frequently. While Docker Compose is significantly simpler than Kubernetes, it ultimately became more painful to work with as complexity grew.

Docker Compose also lacked several capabilities I needed, including scalable and manageable networking, service rollback, distributed storage, and failover.

To manage deployments, I use FluxCD for GitOps-based synchronization and automated rollouts. For secrets management and cluster bootstrapping, I run an external HashiCorp Vault instance in the cloud. Secrets are injected into the cluster using the External Secrets Operator.

A major requirement for this setup was identity management with proper role-based access control. I have multiple people accessing different services, and I didn’t want to require everyone to install a VPN client. As a result, many services are exposed publicly. To secure them, I use Authentik as an identity provider, gating access through OAuth and proxy authentication. Authentik also serves as my LDAP provider.

Overall, moving from Docker Compose to Kubernetes was a good decision, but only once it became necessary. Kubernetes introduced a lot of pain and frustration during the learning process, but the end result has been far more stable and reliable.

My goal was fully declarative infrastructure, where configuration changes are automatically rolled out, paired with a strong observability and uptime monitoring stack. This allows me to catch and fix issues before they become user-visible—or before my girlfriend notices.

At this point, the cluster has maintained roughly nine months of uptime, with no significant or catastrophic failures in quite some time.

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
- **[Istio (Only Ingress Gateway)](https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/)**: Manages ingress traffic to the cluster. Migrated because ingress nginx got deprecated, but I got a performance boost so cool.
- **[Cloudflared](https://github.com/cloudflare/cloudflared)**: Manages ingress traffic to the cluster.
- **[LGTM Monitoring Stack](https://github.com/grafana/loki)**: Includes Prometheus and Grafana for monitoring and visualization.
- **[HashiCorp Vault](https://www.vaultproject.io/)**: Manages secrets and encryption keys.
- **[RustFS](https://rustfs.com/)**: Open source s3 replacement. MinIO broke / paywalled all their useful features so I'm going with this.

## 📲 Applications Running in the Cluster

### Games

- **[SillyTavern](https://github.com/sillytavern/SillyTavern)**: AI roleplay web ui.
- **[Minecraft](https://www.minecraft.net/)**: Minecraft server

### 🗂️ Databases

- **[Cloudnative PG](https://cloudnative-pg.io/)**: A PostgreSQL operator for managing PostgreSQL clusters.
- **[Redis](https://redis.io)**: Low latency key-value store.
- **[EMQX](https://www.emqx.com/)**: An open-source MQTT broker. Also paywalled, so I'll replace it soon.

## 🏠 Smart Home

- **[Home Assistant](https://home-assistant.io/)** : Smart home automation platform
- **[Frigate](https://frigate.video)**: Open source security camera NVR with object detection.
- **[Neolink](https://github.com/QuantumEntangledAndy/neolink)**: Lets you connect reolink proprietary cameras to frigate.

### 📺 Media Apps

- **[Jellyfin](https://jellyfin.org/)**: A media server for streaming and organizing media.

### 🪪 Identity Management

- **[Authentik](https://goauthentik.io/)**: An identity provider for authentication and authorization.

### 🔒 Security

- **[Falco](https://falco.org/)**: Generates container runtime security events.

## 🧰 Hardware

### 🗄️ **Dell EMC PowerEdge C6400** : Power hungry blade server chassis

- 3 x C6420 : server blades
- 1x Intel® Xeon® Gold 6132 Processor
- 64gb DDR4 Memory
- 10 gigabit RJ45 NIC

### 🖥️ **Intel NUC9VXQNX**: Mini PC/Server

- Intel® Xeon® Intel Xeon E-2286M Processor
- 64GB DDR4 Memory
- 10 gigabit SFP+ card
