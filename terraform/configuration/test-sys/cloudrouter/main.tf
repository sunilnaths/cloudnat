###############################################################################
# ROOT: cloudrouter main.tf
###############################################################################

module "cloud_router" {
  source = "../../modules/cloud-router"

  for_each   = local.vpc_router_configs
  vpc_config = each.value
}

