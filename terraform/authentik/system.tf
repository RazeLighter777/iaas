resource "authentik_service_connection_kubernetes" "local" {
  name  = "local"
  local = true
}

resource "authentik_outpost" "proxyoutpost" {
  name               = "proxy-outpost"
  type               = "proxy"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
    module.sonarr.proxy_provider_id,
    module.radarr.proxy_provider_id,
    module.sillytavern.proxy_provider_id,
    module.qbittorrent.proxy_provider_id,
    module.prowlarr.proxy_provider_id,
    module.prometheus.proxy_provider_id,
    module.alertmanager.proxy_provider_id,
    module.booktok.proxy_provider_id,
    module.cwa.proxy_provider_id,
    module.bazarr.proxy_provider_id,
    module.wg.proxy_provider_id,
    module.longhorn.proxy_provider_id,
    module.gatus.proxy_provider_id,
    module.frigate.proxy_provider_id,
    module.loki.proxy_provider_id,
    module.openbooks.proxy_provider_id,
    module.zigbee2mqtt.proxy_provider_id,
    module.zwavejsui.proxy_provider_id,
    module.ircbooksearch.proxy_provider_id
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
    kubernetes_namespace    = "authentik",
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

resource "authentik_outpost" "ldapoutpost" {
  name               = "ldap-outpost"
  type               = "ldap"
  service_connection = authentik_service_connection_kubernetes.local.id
  protocol_providers = [
    authentik_provider_ldap.jellyfin.id,
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
    kubernetes_namespace    = "authentik",
    kubernetes_ingress_annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-issuer"
    },
    kubernetes_ingress_secret_name = "ldap-outpost-tls",
    kubernetes_ingress_class_name     = "nginx",
    kubernetes_service_type        = "ClusterIP",
    kubernetes_disabled_components = [],
    kubernetes_image_pull_secrets  = []
  })
}

    

