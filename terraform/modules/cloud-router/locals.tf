locals {
  # Direct inputs
  project_id = var.project_id
  prefix     = var.prefix
  vpc_name   = var.vpc_name
  network    = var.network

  # Build router list
  routers = flatten([
    for region_name, region_cfg in var.regions : [
      for r in region_cfg.routers : {
        key         = "${local.vpc_name}|${region_name}|${r.name}"
        vpc_name    = local.vpc_name
        region_name = region_name
        router_name = r.name
        description = try(r.description, null)
        asn         = try(r.asn, null)
        project_id  = local.project_id
        prefix      = local.prefix
        network     = local.network

        # final name: snt-vpc-a-cr-uscentral1-02
        final_name = format(
          "%s-%s-cr-%s-%s",
          local.prefix,
          local.vpc_name,
          replace(region_name, "-", ""),
          r.name
        )
      }
    ]
  ])

  routers_map = { for r in local.routers : r.key => r }
}

