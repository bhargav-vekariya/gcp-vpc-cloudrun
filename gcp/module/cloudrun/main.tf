resource "google_cloud_run_v2_service" "r_cloudrun" {
  for_each = var.Resources.CloudRunResource
  name     = each.value.name
  location = each.value.location

  dynamic "template" {
    for_each = each.value.template
    content {
      revision    = can(template.value.revision) ? template.value.revision : null
      labels      = can(template.value.labels) ? template.value.labels : null
      annotations = can(template.value.annotations) ? template.value.annotations : null
      dynamic "scaling" {
        for_each = can(template.value.scaling) ? template.value.scaling : {}
        content {
          min_instance_count = can(scaling.value.min_instance_count) ? scaling.value.min_instance_count : null
          max_instance_count = can(scaling.value.max_instance_count) ? scaling.value.max_instance_count : null
        }
      }
      dynamic "vpc_access" {
        for_each = can(template.value.vpc_access) ? template.value.vpc_access : {}
        content {
          connector = can(vpc_access.value.connector) ? vpc_access.value.connector : null
          egress    = can(vpc_access.value.egress) ? vpc_access.value.egress : null
          dynamic "network_interfaces" {
            for_each = can(vpc_access.value.network_interfaces) ? vpc_access.value.network_interfaces : {}
            content {
              network    = can(network_interfaces.value.network) ? network_interfaces.value.network : null
              subnetwork = can(network_interfaces.value.subnetwork) ? network_interfaces.value.subnetwork : null
              tags       = can(network_interfaces.value.tags) ? network_interfaces.value.tags : null

            }
          }
        }
      }
      timeout         = can(template.value.timeout) ? template.value.timeout : null
      service_account = can(template.value.service_account) ? template.value.service_account : null
      dynamic "containers" {
        for_each = can(template.value.containers) ? template.value.containers : null
        content {
          name    = can(containers.value.name) ? containers.value.name : null
          image   = containers.value.image
          command = can(containers.value.command) ? containers.value.command : null
          args    = can(containers.value.args) ? containers.value.args : null
          dynamic "env" {
            for_each = can(containers.value.env) ? containers.value.env : {}
            content {
              name  = env.value.name
              value = can(env.value.value) ? env.value.value : null
              dynamic "value_source" {
                for_each = can(env.value.value_source) ? env.value.value_source : {}
                content {
                  dynamic "secret_key_ref" {
                    for_each = value_source.value.secret_key_ref ? value_source.value.secret_key_ref : {}
                    content {
                      secret  = secret_key_ref.value.secret
                      version = secret_key_ref.value.version
                    }
                  }
                }

              }
            }
          }
          resources {
            limits            = can(containers.value.limits) ? containers.value.limits : null
            cpu_idle          = can(containers.value.cpu_idle) ? containers.value.cpu_idle : null
            startup_cpu_boost = can(containers.value.startup_cpu_boost) ? containers.value.startup_cpu_boost : null
          }
          ports {
            name           = can(containers.value.name) ? containers.value.name : null
            container_port = can(containers.value.container_port) ? containers.value.container_port : null
          }
          dynamic "volume_mounts" {
            for_each = can(containers.value.volume_mounts) ? containers.value.volume_mounts : {}
            content {
              name       = volume_mounts.value.name
              mount_path = volume_mounts.value.mount_path
            }
          }

          working_dir = can(containers.value.working_dir) ? containers.value.working_dir : null
          dynamic "liveness_probe" {
            for_each = can(containers.value.liveness_probe) ? containers.value.liveness_probe : {}
            content {
              initial_delay_seconds = can(liveness_probe.value.initial_delay_seconds) ? liveness_probe.value.initial_delay_seconds : null
              timeout_seconds       = can(liveness_probe.value.timeout_seconds) ? liveness_probe.value.timeout_seconds : null
              period_seconds        = can(liveness_probe.value.period_seconds) ? liveness_probe.value.period_seconds : null
              failure_threshold     = can(liveness_probe.value.failure_threshold) ? liveness_probe.value.failure_threshold : null
              tcp_socket {
                port = can(liveness_probe.value.port) ? liveness_probe.value.port : null
              }
              dynamic "http_get" {
                for_each = can(liveness_probe.value.http_get) ? liveness_probe.value.http_get : {}
                content {
                  path = can(http_get.value.path) ? http_get.value.path : null
                  port = can(http_get.value.port) ? http_get.value.port : null
                }
              }
            }
          }
          dynamic "startup_probe" {
            for_each = can(containers.value.startup_probe) ? containers.value.startup_probe : {}
            content {
              initial_delay_seconds = can(startup_probe.value.initial_delay_seconds) ? startup_probe.value.initial_delay_seconds : null
              timeout_seconds       = can(startup_probe.value.timeout_seconds) ? startup_probe.value.timeout_seconds : null
              period_seconds        = can(startup_probe.value.period_seconds) ? startup_probe.value.period_seconds : null
              failure_threshold     = can(startup_probe.value.failure_threshold) ? startup_probe.value.failure_threshold : null
              tcp_socket {
                port = can(startup_probe.value.port) ? startup_probe.value.port : null
              }
              dynamic "http_get" {
                for_each = can(startup_probe.value.http_get) ? startup_probe.value.http_get : {}
                content {
                  path = can(http_get.value.path) ? http_get.value.path : null
                  port = can(http_get.value.port) ? http_get.value.port : null
                }
              }
            }
          }
          depends_on = can(containers.value.depends_on) ? containers.value.depends_on : null
        }
      }
      dynamic "volumes" {
        for_each = can(template.value.volumes) ? template.value.volumes : {}
        content {
          name = volumes.value.name
          gcs {
            bucket    = volumes.value.bucket
            read_only = can(volumes.value.read_only) ? volumes.value.bucket : null
          }

        }
      }
    }
  }

}


data "google_iam_policy" "d_noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "r_noauth" {
  for_each = var.Resources.Noauth
  location    = google_cloud_run_v2_service.r_cloudrun[each.value.cloudrun_resource_key].location
  project     = google_cloud_run_v2_service.r_cloudrun[each.value.cloudrun_resource_key].project
  service     = google_cloud_run_v2_service.r_cloudrun[each.value.cloudrun_resource_key].name
  policy_data = data.google_iam_policy.d_noauth.policy_data
}
