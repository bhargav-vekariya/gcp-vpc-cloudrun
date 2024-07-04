output "o_vpc_id" {
    
    value = {for vpc_id,vpcs in module.m_vpc.o_vpc_ids : vpc_id => vpcs.id}
}

output "o_subnet_id" {
    value = {for subnet_id,subnets in module.m_vpc.o_subnet_ids: subnet_id => subnets.id }
}