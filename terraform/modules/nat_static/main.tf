###############################################################################
# MAIN LOGIC - CREATE STATIC IPS AND CLOUD NATS
###############################################################################

resource "google_compute_address" "nat_ip" {
  for_each     = local.nat_ip_map
  project      = each.value.project_id
  name         = local.truncate_name[each.key]
  region       = each.value.region
  address_type = "EXTERNAL"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat" "nat" {
  for_each = local.nats_map

  project = each.value.project_id
  name    = each.value.nat_name
  router  = each.value.router_name
  region  = each.value.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips = [
    for i in range(each.value.address_count) :
    google_compute_address.nat_ip["${each.key}|${i}"].self_link
  ]

  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation
  drain_nat_ips                       = each.value.drain_nat_ips

  min_ports_per_vm = each.value.min_ports_per_vm
  max_ports_per_vm = each.value.max_ports_per_vm

  udp_idle_timeout_sec             = each.value.udp_idle_timeout_sec
  icmp_idle_timeout_sec            = each.value.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec = each.value.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec  = each.value.tcp_transitory_idle_timeout_sec
  tcp_time_wait_timeout_sec        = each.value.tcp_time_wait_timeout_sec

  source_subnetwork_ip_ranges_to_nat = each.value.source_subnetwork_ip_ranges_to_nat

  dynamic "subnetwork" {
    for_each = each.value.subnetworks
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = try(subnetwork.value.secondary_ip_range_names, [])
    }
  }

  log_config {
    enable = each.value.log_enable
    filter = each.value.log_filter
  }

  dynamic "rules" {
    for_each = each.value.rules
    content {
      rule_number = rules.value.rule_number
      description = try(rules.value.description, "Rule ${rules.value.rule_number}")
      match       = try(rules.value.match, "SRC_IPS_ALL")

      action {
        source_nat_active_ips = try(rules.value.action.source_nat_active_ips, null) == "ALL" ? (
          [
            for i in range(each.value.address_count) :
            google_compute_address.nat_ip["${each.key}|${i}"].self_link
          ]
        ) : try(rules.value.action.source_nat_active_ips, [])
      }
    }
  }

  depends_on = [google_compute_address.nat_ip]
}



#####################################################


# ============================================================================
# AUTOMATIC JSON OUTPUT FILES - Saved to outputs/ directory
# ============================================================================

# Save all IPs organized by VPC and Region
resource "local_file" "ips_by_vpc_region" {
  filename = "${path.root}/outputs/ips_by_vpc_region.json"

  content = jsonencode({
    for ip_key, ip_obj in google_compute_address.nat_ip :
    "${split("|", ip_key)[0]}|${split("|", ip_key)[1]}" => {
      vpc    = split("|", ip_key)[0]
      region = split("|", ip_key)[1]
      ips = [
        for ik, io in google_compute_address.nat_ip :
        {
          name    = io.name
          address = io.address
        } if "${split("|", ik)[0]}|${split("|", ik)[1]}" == "${split("|", ip_key)[0]}|${split("|", ip_key)[1]}"
      ]
    }...
  })

  depends_on = [google_compute_address.nat_ip]
}


