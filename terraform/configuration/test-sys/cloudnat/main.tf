module "cloud_nat" {
  for_each = local.vpc_configs

  source = "../../modules/nat_static"

  vpc_config = each.value
}



