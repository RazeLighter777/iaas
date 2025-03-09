resource "authentik_service_connection_kubernetes" "local" {
  name  = "local"
  local = true
}

resource "authentik_outpost" "proxyoutpost" {
  name               = "proxy-outpost"
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
  ]
  config = jsonencode({
    authentik_host          = "https://authentik.${var.domain_name}",
    authentik_host_insecure = false,
    authentik_host_browser  = "",
    log_level               = "debug",
    object_naming_template  = "ak-outpost-%(name)s",
    docker_network          = null,
    docker_map_ports        = true,
    docker_labels           = null,
    container_image         = null,
    kubernetes_replicas     = 1,
    kubernetes_namespace    = "security",
    kubernetes_ingress_annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-issuer"
    },
    kubernetes_ingress_secret_name = "proxy-outpost-tls",
    kubernetes_ingress_class_name     = "nginx",
    kubernetes_service_type        = "ClusterIP",
    kubernetes_disabled_components = [],
    kubernetes_image_pull_secrets  = []
  })
}