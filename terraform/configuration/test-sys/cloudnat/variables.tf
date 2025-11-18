variable "common_config_path" {
  description = "Path to common NAT config file"
  type        = string
  default     = null
}

variable "configs_path" {
  description = "Path to all VPC NAT YAML files"
  type        = string
  default     = null
}
