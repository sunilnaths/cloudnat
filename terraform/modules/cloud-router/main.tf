resource "google_compute_router" "router" {
  for_each = local.routers_map

  name    = each.value.final_name
  project = each.value.project_id
  region  = each.value.region_name
  network = each.value.network

  dynamic "bgp" {
    for_each = each.value.asn != null ? [each.value.asn] : []

    content {
      asn = bgp.value
    }
  }
}
