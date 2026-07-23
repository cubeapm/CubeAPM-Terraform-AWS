// print all the VPC's details as output
output "vpcs" {
  value = {
    for id, vpc in data.aws_vpc.details :
    id => {
      name = try(vpc.tags["Name"], "no-name")
      cidr = vpc.cidr_block
    }
  }
}

// print the details of selected VPC's subnets.
output "subnets" {
  value = {
    for id, subnet in data.aws_subnet.details :
    id => {
      name = try(subnet.tags["Name"], "no-name")
      cidr = subnet.cidr_block
      az   = subnet.availability_zone
    }
  }
}

// print the details of cubeapm instance.
output "instance_id" {
  value = aws_instance.cubeapm_instance.id
}
