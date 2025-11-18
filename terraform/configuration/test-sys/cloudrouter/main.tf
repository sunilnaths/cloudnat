###############################################################################
# ROOT: cloudrouter main.tf
###############################################################################

module "cloud_nat" {
  source = "../../modules/nat_static"

  for_each = local.vpc_configs

  vpc_config = each.value
  # common_config_path = var.common_config_path
  configs_path = var.configs_path
}
