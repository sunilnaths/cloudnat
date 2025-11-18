locals {

  # Apply defaults when variables are null
  common_config_path = (
    var.common_config_path != null ?
    var.common_config_path :
    "${path.module}/configs/common-config/common.yaml"
  )

  configs_path = (
    var.configs_path != null ?
    var.configs_path :
    "${path.module}/configs/cloud-nat-yaml"
  )

  # Load common.yaml
  common = yamldecode(file(local.common_config_path))

  # Load each VPC YAML file
  vpc_yaml_files = fileset(local.configs_path, "*.yaml")

  vpc_configs = {
    for f in local.vpc_yaml_files :
    trimsuffix(f, ".yaml") => merge(
      yamldecode(file("${local.configs_path}/${f}")),
      local.common
    )
  }
}
