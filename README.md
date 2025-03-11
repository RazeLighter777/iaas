# 🏠 Kubernetes Homelab


Welcome to my Kubernetes Homelab! This repository contains all the necessary configurations and scripts to set up a fully functional Kubernetes cluster at home.



## 📁 Directory Structure


```plaintext.├── .gitignore├── .sops.yaml├── README.md├── renovate.json├── cluster/│   ├── apps/│   │   ├── media/│   │   └── sillytavern/│   ├── bootstrap/│   │   ├── apps.yaml│   │   ├── infrastructure.yaml│   │   ├── kustomization.yaml│   │   ├── platforms.yaml│   │   ├── settings.yaml│   │   ├── sources.yaml│   │   └── flux-system/│   ├── infrastructure/│   │   ├── cert-manager/│   │   ├── democratic-csi/│   │   ├── external-dns/│   │   ├── ingress-nginx/│   │   ├── intel-gpu-plugin/│   │   ├── metallb/│   │   └── monitoring/│   ├── platforms/│   ├── settings/│   └── sources/└── talos/    ├── bootstrap.sh    ├── outputs.tf    ├── providers.tf    ├── proxmox_secrets.sops.yaml    ├── proxmox.tf    └── files/        └── templates/
```

## 🚀 Getting Started

### Prerequisites

- [Docker](https://www.docker.com/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/)
- [Talos](https://www.talos.dev/)

### Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/yourusername/homelab.git
    cd homelab
    ```

2. **Bootstrap the cluster:**

    ```sh
    ./talos/bootstrap.sh
    ```

3. **Apply the configurations:**

    ```sh
    kubectl apply -k cluster/bootstrap
    ```

## 📦 Components

### Infrastructure

- **Cert-Manager:** Manages SSL/TLS certificates.
- **Democratic-CSI:** Provides CSI storage.
- **External-DNS:** Manages DNS records.
- **Ingress-Nginx:** Ingress controller.
- **Intel-GPU-Plugin:** GPU support.
- **MetalLB:** Load balancer.
- **Monitoring:** Prometheus and Grafana.

### Applications

- **Media:** Media server applications.
- **SillyTavern:** Example application.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [Talos](https://www.talos.dev/)
- [Kubernetes](https://kubernetes.io/)
- [Flux](https://fluxcd.io/)

---

Happy Homelabbing! 🚀