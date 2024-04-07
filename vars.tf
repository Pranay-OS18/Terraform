variable "Region" {
  default = "ap-south-1"
}
variable "CIDR_Block" {
  default = "192.168.0.0/16"
}
variable "subnet_cidrs" {
  type = list(string)
  description = "Subnet CIDR Values"
  default = [ "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24" ]
}
variable "azs" {
  type = list(string)
  description = "Availability Zones"
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
variable "AMI" {
    default = "ami-007020fd9c84e18c7" #Ubuntu-22.04
}
variable "instance-config" {
    default = "t2.medium"
}
