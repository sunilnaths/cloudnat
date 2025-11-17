variable "configs_path" {
  description = "Path to VPC router YAML files"
  type        = string
}

variable "common_config_path" {
  description = "Common config YAML containing shared variables (project_id, prefix)"
  type        = string
}
