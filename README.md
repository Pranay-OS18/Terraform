This Terraform configuration creates a Virtual Private Cloud (VPC) in the specified AWS region along with three subnets. An Internet Gateway (IGW) is created and attached to the VPC, enabling public internet routing to all three subnets using a Route Table. Additionally, seven EC2 instances are provisioned across two different subnets, each with Allow-All rules defined in their respective Security Groups.

All configurable variables are defined in the vars.tf file. Update these variables as needed to customize the VPC, subnet, and EC2 instance configurations.
