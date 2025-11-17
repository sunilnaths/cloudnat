###############################################################################
# MODULE: cloud-router
# PURPOSE: Create google_compute_router resources per VPC/region/router
###############################################################################

resource "google_compute_router" "router" {
  for_each = local.routers_map

  project = each.value.project_id
  region  = each.value.region
  network = each.value.network

  # Name pattern: snt-vpc-a-cr-uscentral1-router-1  (trimmed to 63 chars)
  name = substr(
    format(
      "%s-%s-cr-%s-%s",
      local.prefix,
      each.value.vpc_name,
      replace(each.value.region, "-", ""),
      each.value.router_name
    ),
    0,
    63
  )

  description = each.value.description

  # Only create BGP block if ASN is provided in YAML
  dynamic "bgp" {
    for_each = each.value.asn == null ? [] : [1]
    content {
      asn = each.value.asn
    }
  }
}

# Optional output for debugging / wiring into other modules
output "routers" {
  description = "Created Cloud Routers for this VPC"
  value = {
    for k, r in google_compute_router.router :
    k => {
      name      = r.name
      region    = r.region
      project   = r.project
      network   = r.network
      self_link = r.self_link
    }
  }
}
