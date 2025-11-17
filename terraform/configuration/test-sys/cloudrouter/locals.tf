locals {
  # Load common.yaml only once
  cr_common = yamldecode(file("${path.module}/configs/common-config/common.yaml"))

  # Load all per-VPC router YAMLs
  vpc_router_configs = {
    for f in fileset("${path.module}/configs/cloud-router-yaml", "*.yaml") :
    trimsuffix(f, ".yaml") => yamldecode(file("${path.module}/configs/cloud-router-yaml/${f}"))
  }
}
