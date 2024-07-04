resource "google_compute_network" "r_network" {
  for_each                = var.Resources.VPCResource
  name                    = each.value.name
  project                 = can(each.value.project) ? each.value.project : null
  auto_create_subnetworks = can(each.value.auto_create_subnetworks) ? each.value.auto_create_subnetworks : false
}

resource "google_compute_subnetwork" "r_network-private-ip-ranges" {
  for_each      = var.Resources.SubnetResource
  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = can(each.value.region) ? each.value.region : null
  network       = google_compute_network.r_network[each.value.network_resource_key].id
  dynamic "secondary_ip_range" {
    for_each = can(each.value.secondary_ip_range) ? each.value.secondary_ip_range : {}
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}
