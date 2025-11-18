variable "common_config_path" {
  description = "Path to common.yaml"
  type        = string
  default     = "${path.module}/configs/common-config/common.yaml"
}

variable "configs_path" {
  description = "Path to NAT YAMLs"
  type        = string
  default     = "${path.module}/configs/cloud-nat-yaml"
}

