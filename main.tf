/*This configuration will create a VPC and three subnets in aws region.
An Internet Gateway will be created and attached to VPC, allowing public internet routing to all three subnets using Route Table.
Also, Seven EC2's will be created in two different subnets with Allow-All rules defined in Security Group.
All variable defined in vars.tf file.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

provider "aws" {
  region = var.Region
}

resource "aws_vpc" "PV-NW" {
  cidr_block       = var.CIDR_Block
  instance_tenancy = "default"
  tags = {
    Name = "Core-NW-Layer"
  }
}

resource "aws_subnet" "subnets" {
  vpc_id                  = aws_vpc.PV-NW.id
  count                   = length(var.subnet_cidrs)
  map_public_ip_on_launch = "true"
  cidr_block              = element(var.subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  tags = {
    Name = "Core-SN ${count.index + 1}"
  }
}
# Internet Gateway Creation
resource "aws_internet_gateway" "Public-IGW" {
  vpc_id = aws_vpc.PV-NW.id
  tags = {
    Name = "Core-IGW"
  }
}

# Route Table Creation & Association
resource "aws_route_table" "Internet-Route" {
  vpc_id = aws_vpc.PV-NW.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Public-IGW.id
  }
}
resource "aws_route_table_association" "Public-Route" {
  count          = length(aws_subnet.subnets)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.Internet-Route.id
}

#Security Group & Rules Creation//Allow All Configuration
resource "aws_security_group" "Allow-TLS-All" {
  vpc_id = aws_vpc.PV-NW.id
  tags = {
    Name = "Secure-SG"
  }
  ingress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow-All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Creation
resource "aws_instance" "Controllers" {
  ami                    = var.AMI
  instance_type          = var.instance-config
  key_name               = "Master-Key"
  vpc_security_group_ids = [aws_security_group.Allow-TLS-All.id]
  subnet_id              = aws_subnet.subnets[0].id
  for_each               = toset(["Ansible-Controller", "Jenkins-Controller", "K8s-Control-Plane", "Code-Machine"])
  tags = {
    Name = "${each.key}"
  }
}

resource "aws_instance" "Servers" {
  ami                    = var.AMI
  instance_type          = var.instance-config
  key_name               = "Master-Key"
  vpc_security_group_ids = [aws_security_group.Allow-TLS-All.id]
  subnet_id              = aws_subnet.subnets[1].id
  for_each               = toset(["Jenkins-Slave", "K8s-Slave-01", "K8s-Slave-02"])
  tags = {
    Name = "${each.key}"
  }
}
