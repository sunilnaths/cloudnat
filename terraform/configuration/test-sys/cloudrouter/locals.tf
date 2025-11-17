###############################################################################
# ROOT: cloudrouter locals.tf
###############################################################################

locals {
  # Load common.yaml (project_id, naming prefix, etc.)
  common = yamldecode(file(var.common_config_path))

  # Find VPC router YAML files
  router_files = fileset(var.configs_path, "*.yaml")

  # Load + decode each router YAML file
  vpc_router_configs = {
    for f in local.router_files :
    # Key = vpc_name found in YAML
    yamldecode(file("${var.configs_path}/${f}")).vpc_name => (
      merge(
        local.common,
        yamldecode(file("${var.configs_path}/${f}"))
      )
    )
  }
}
