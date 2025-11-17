###############################################################################
# MODULE LOCALS - Build Maps for Dynamic Resource Creation
# Purpose: Transform hierarchical VPC config into flat maps for for_each
###############################################################################

locals {
  vpc        = var.vpc_config
  vpc_name   = local.vpc.vpc_name
  project_id = local.vpc.project_id
  prefix     = try(local.vpc.naming_prefix, "snt")

  ###############################################################################
  # STEP 1: Flatten router hierarchy (Region → Router)
  ###############################################################################
  routers = flatten([
    for region_name, region in try(local.vpc.regions, {}) : [
      for router_name, router in try(region.routers, {}) : {
        vpc_name    = local.vpc_name
        project_id  = local.project_id
        region_name = region_name
        router_name = router_name
        cloud_nats  = try(router.cloud_nats, [])
      }
    ]
  ])

  ###############################################################################
  # STEP 2: Flatten NAT hierarchy (Router → NAT)
  # Each NAT gets a composite key: vpc|region|router|nat_name
  ###############################################################################
  nats = flatten([
    for router in local.routers : [
      for nat in router.cloud_nats : {
        # Composite key ensures uniqueness across all NATs across all VPCs
        key         = "${router.vpc_name}|${router.region_name}|${router.router_name}|${nat.name}"
        vpc_name    = router.vpc_name
        project_id  = router.project_id
        region      = router.region_name
        router_name = router.router_name
        prefix      = local.prefix

        # Extract numeric suffix from NAT name (e.g., "nat1" → 1, "nat" → 1)
        nat_number = tonumber(try(regexall("\\d+", nat.name)[0], 1))

        # Cloud NAT resource name: snt-vpc-a-nat-uscentral1-01
        # Pattern: {prefix}-{vpc}-nat-{region_compact}-{number}
        nat_name = substr(
          format(
            "%s-%s-nat-%s-%02d",
            local.prefix,
            router.vpc_name,
            replace(router.region_name, "-", ""),           # Remove hyphens (us-central1 → uscentral1)
            tonumber(try(regexall("\\d+", nat.name)[0], 1)) # Calculate inline (can't reference nat_number yet)
          ),
          0,
          63 # GCP resource name max length
        )

        # NAT configuration from YAML with defaults
        address_count                       = try(nat.address_count, 1)
        min_ports_per_vm                    = try(nat.min_ports_per_vm, 2048)
        max_ports_per_vm                    = try(nat.max_ports_per_vm, null)
        enable_dynamic_port_allocation      = try(nat.enable_dynamic_port_allocation, false)
        enable_endpoint_independent_mapping = try(nat.enable_endpoint_independent_mapping, true)

        # Timeout configurations (in seconds)
        udp_idle_timeout_sec             = try(nat.udp_idle_timeout_sec, 30)
        icmp_idle_timeout_sec            = try(nat.icmp_idle_timeout_sec, 30)
        tcp_established_idle_timeout_sec = try(nat.tcp_established_idle_timeout_sec, 1200)
        tcp_transitory_idle_timeout_sec  = try(nat.tcp_transitory_idle_timeout_sec, 30)
        tcp_time_wait_timeout_sec        = try(nat.tcp_time_wait_timeout_sec, 120)

        # Logging configuration
        log_enable = try(nat.log_enable, true)
        log_filter = try(nat.log_filter, "ERRORS_ONLY") # ERRORS_ONLY, TRANSLATIONS_ONLY, or ALL

        # Subnetwork source ranges
        subnetworks = try(nat.subnetworks, [])
        source_subnetwork_ip_ranges_to_nat = try(
          nat.source_subnetwork_ip_ranges_to_nat,
          "ALL_SUBNETWORKS_ALL_IP_RANGES" # ALT: SUBNETWORK_IP_RANGES
        )

        # Advanced configurations
        drain_nat_ips = try(nat.drain_nat_ips, [])
        rules         = try(nat.rules, [])
      }
    ]
  ])

  ###############################################################################
  # STEP 3: Create IP reservation list
  # For each NAT with multiple addresses, create an entry per IP
  # Each IP gets: vpc|region|router|nat|address_index
  ###############################################################################
  nat_ip_list = flatten([
    for n in local.nats : [
      for i in range(n.address_count) : {
        key         = "${n.key}|${i}" # Global unique key including IP index
        project_id  = n.project_id
        vpc_name    = n.vpc_name
        region      = n.region
        router_name = n.router_name
        prefix      = n.prefix
        nat_number  = n.nat_number
        index       = i + 1 # 1-based index for naming
      }
    ]
  ])

  ###############################################################################
  # STEP 4: Build maps for resource creation
  # These maps are used in resource for_each blocks
  ###############################################################################
  nat_ip_map = { for ip in local.nat_ip_list : ip.key => ip }
  nats_map   = { for nat in local.nats : nat.key => nat }

  ###############################################################################
  # STEP 5: Generate static IP names
  # Pattern: snt-vpc-a-nat-reservedip01-uscentral1-01
  # This ensures globally unique names across all projects/VPCs
  ###############################################################################
  truncate_name = {
    for key, ip in local.nat_ip_map :
    key => substr(
      format(
        "%s-%s-nat-reservedip%02d-%s-%02d",
        ip.prefix,
        ip.vpc_name,
        ip.index,                    # 01, 02, 03... per NAT
        replace(ip.region, "-", ""), # Remove hyphens
        ip.nat_number                # NAT instance number
      ),
      0,
      63 # GCP resource name max length
    )
  }

  ###############################################################################
  # OPTIONAL: Summary statistics for debugging
  ###############################################################################
  summary = {
    vpc_name       = local.vpc_name
    project_id     = local.project_id
    region_count   = length(try(local.vpc.regions, {}))
    router_count   = length(local.routers)
    nat_count      = length(local.nats)
    total_ip_count = length(local.nat_ip_list)
    nats_per_region = {
      for r in local.routers : r.region_name => length([
        for n in local.nats : n if n.region == r.region_name
      ])
    }
  }
}
