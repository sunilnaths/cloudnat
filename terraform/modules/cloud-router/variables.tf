variable "vpc_name" { type = string }
variable "network" { type = string }
variable "regions" {
  type = map(object({
    routers = list(object({
      name        = string
      description = optional(string)
      asn         = optional(number)
    }))
  }))
}
variable "project_id" { type = string }
variable "prefix" { type = string }

