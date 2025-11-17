###############################################################################
# ROOT: cloudrouter main.tf
###############################################################################

module "cloud_router" {
  for_each = local.vpc_router_configs

  source = "../../modules/cloud-router"

  vpc_name = each.value.vpc_name
  network  = each.value.network
  regions  = each.value.regions

  project_id = local.cr_common.project_id
  prefix     = local.cr_common.naming_prefix
}
