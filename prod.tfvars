# VPC
vpc_cidr              = "10.0.0.0/24"
public_subnet_a_cidr  = "10.0.0.0/26"
public_subnet_b_cidr  = "10.0.0.64/26"
private_subnet_a_cidr = "10.0.0.128/26"
private_subnet_b_cidr = "10.0.0.192/26"

# Route 53
r53_public_domain  = "mydomain.net"
r53_private_domain = "internal.mydomain.net"


# ALB
allowed_customers_mngr_consumers = ["11.0.0.0/24", "12.0.0.0/24"] # as an example