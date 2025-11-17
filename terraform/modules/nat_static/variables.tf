variable "vpc_config" {
  description = "VPC configuration containing regions, routers, and Cloud NATs"
  type = object({
    vpc_name      = string
    project_id    = string
    naming_prefix = optional(string, "snt")
    regions = map(object({
      routers = map(object({
        cloud_nats = list(object({
          name                                = string
          address_count                       = optional(number, 1)
          min_ports_per_vm                    = optional(number, 2048)
          max_ports_per_vm                    = optional(number, null)
          enable_dynamic_port_allocation      = optional(bool, false)
          enable_endpoint_independent_mapping = optional(bool, true)
          drain_nat_ips                       = optional(list(string), [])
          udp_idle_timeout_sec                = optional(number, 30)
          icmp_idle_timeout_sec               = optional(number, 30)
          tcp_established_idle_timeout_sec    = optional(number, 1200)
          tcp_transitory_idle_timeout_sec     = optional(number, 30)
          tcp_time_wait_timeout_sec           = optional(number, 120)
          log_enable                          = optional(bool, true)
          log_filter                          = optional(string, "ERRORS_ONLY")
          source_subnetwork_ip_ranges_to_nat  = optional(string, "ALL_SUBNETWORKS_ALL_IP_RANGES")
          subnetworks = optional(list(object({
            name                     = string
            source_ip_ranges_to_nat  = list(string)
            secondary_ip_range_names = optional(list(string), [])
          })), [])
          rules = optional(list(object({
            rule_number = number
            description = optional(string)
            match       = optional(string, "SRC_IPS_ALL")
            action = optional(object({
              source_nat_active_ips = optional(list(string), [])
            }), {})
          })), [])
        }))
      }))
    }))
  })
  nullable = false
}
