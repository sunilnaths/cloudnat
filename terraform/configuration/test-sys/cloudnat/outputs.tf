
# # # output "static_ips_created" {
# # #   description = "Static IP addresses created per VPC"
# # #   value = {
# # #     for vpc_name, module_output in module.cloud_nat :
# # #     vpc_name => {
# # #       for ip_key, ip_resource in module_output.nat_ip_resources :
# # #       ip_resource.name => ip_resource.address
# # #     }
# # #   }
# # # }

# # output "deployment_complete" {
# #   description = "Deployment summary"
# #   value = {
# #     message = "Cloud NAT infrastructure deployed successfully"
# #     vpcs    = keys(module.cloud_nat)
# #   }
# # }



# output "debug_vpc_c" {
#   value = module.cloud_nat["vpc-c"]
# }
output "deployment_complete" {
  value = {
    message = "Cloud NAT deployment completed"
    vpcs    = keys(local.vpc_configs)
  }
}

