module "cloud_nat" {
  for_each = local.vpc_configs

  source = "../../modules/nat_static"

  vpc_config         = each.value
  common_config_path = local.common_config_path
}
