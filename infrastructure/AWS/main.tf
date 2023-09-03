
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provides EC2 key pair
resource "aws_key_pair" "terraformkey" {
  key_name   = "terraform_key"
  public_key = tls_private_key.k8s_ssh.public_key_openssh
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block       = "10.0.0.0/16" # 65,536 IP addresses
  enable_dns_hostnames=true
  enable_dns_support =true

  tags = {
    Name = "K8S VPC"
  }
}

# Create Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.k8s_vpc.id
  cidr_block = "172.15.10.0/24" # 256 IP addresses
  map_public_ip_on_launch = true
  availability_zone = var.aws_region
  tags = {
    Name = "Public Subnet"
  }
}


resource "aws_route_table" "k8s_route" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_gw.id
  }

  tags = {
    Name = "K8S Route"
  }
}

resource "aws_route_table_association" "k8s_asso" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.k8s_route.id
}

resource "aws_internet_gateway" "k8s_gw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "K8S Gateway"
  }
}


# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  profile =  "amy"
}

# Create a VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "K8S VPC"
  }
}