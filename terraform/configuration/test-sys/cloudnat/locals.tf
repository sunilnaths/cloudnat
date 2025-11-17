# BLOCK 1: Load common configuration
locals {
  common_config = try(
    yamldecode(file(var.common_config_path)),
    {}
  )
}

# BLOCK 2: Find VPC files and load configs
locals {
  # Find all VPC YAML files (excluding common-config directory)
  vpc_yaml_files = [
    for f in fileset(var.configs_path, "*.yaml") :
    f if f != "common-config/common.yaml"
  ]

  # Load and merge each VPC config with common config
  vpc_configs = {
    for yaml_file in local.vpc_yaml_files :
    replace(yaml_file, ".yaml", "") => merge(
      local.common_config,
      try(yamldecode(file("${var.configs_path}/${yaml_file}")), {})
    )
  }
}
