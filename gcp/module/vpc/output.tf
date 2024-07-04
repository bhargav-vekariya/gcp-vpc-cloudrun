output "o_vpc_ids" {

    value = google_compute_network.r_network
}

output "o_subnet_ids" {
    value = google_compute_subnetwork.r_network-private-ip-ranges
}