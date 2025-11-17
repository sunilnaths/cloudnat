###############################################################################
# MODULE: cloud-router
# PURPOSE: Build router map from VPC YAML config
###############################################################################

locals {
  vpc        = var.vpc_config
  vpc_name   = local.vpc.vpc_name
  project_id = local.vpc.project_id
  prefix     = try(local.vpc.naming_prefix, "snt")

  # Routers: flatten regions → routers
  routers = flatten([
    for region_name, region_conf in local.vpc.regions : [
      for router_name, router_conf in region_conf.routers : {
        key = "${local.vpc_name}|${region_name}|${router_name}"

        vpc_name    = local.vpc_name
        project_id  = local.project_id
        region      = region_name
        router_name = router_name

        # Network resolution:
        # router_conf.network > region_conf.network > vpc.network
        network = try(
          router_conf.network,
          try(region_conf.network, local.vpc.network)
        )

        description = try(router_conf.description, null)
        asn         = try(router_conf.asn, null) # optional, only if BGP used
      }
    ]
  ])

  routers_map = {
    for r in local.routers :
    r.key => r
  }
}
