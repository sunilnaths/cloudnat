variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "my-gcp-project"
}

variable "configs_path" {
  description = "Path to VPC configuration YAML files"
  type        = string
  default     = "./configs/cloud-nat-yaml"
}

variable "common_config_path" {
  description = "Path to common configuration YAML"
  type        = string
  default     = "./configs/common-config/common.yaml"
}

variable "enable_nat_creation" {
  description = "Enable Cloud NAT resource creation"
  type        = bool
  default     = true
}

