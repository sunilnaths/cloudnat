output "nat_ips" {
  description = "All NAT IP addresses"
  value = {
    for k, addr in google_compute_address.nat_ip :
    k => addr.address
  }
}



output "nat_ip_resources" {
  value = {
    for k, ip in google_compute_address.nat_ip :
    k => { name = ip.name, address = ip.address, region = ip.region, self_link = ip.self_link }
  }
}



# ============================================================================
# TERRAFORM OUTPUTS
# ============================================================================

output "ips_per_vpc_region" {
  description = "IP addresses organized by VPC and Region"
  value = {
    for ip_key, ip_obj in google_compute_address.nat_ip : ip_key => {
      vpc     = split("|", ip_key)[0]
      region  = split("|", ip_key)[1]
      name    = ip_obj.name
      address = ip_obj.address
      index   = split("|", ip_key)[4]
    }
  }
}

output "output_files_location" {
  description = "Location of automatically generated JSON output files"
  value = {
    ips_by_vpc_region = local_file.ips_by_vpc_region.filename

  }
}
