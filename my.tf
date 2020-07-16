provider "aws" {
  region = "ap-south-1"
}

resource "tls_private_key" task1_p_key  {
  algorithm = "RSA"
}


resource "aws_key_pair" "task1-key" {
  key_name    = "task1-key"
  public_key = tls_private_key.task1_p_key.public_key_openssh
  }



resource "aws_vpc" "My_VPC" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
 
tags = {
    Name = "My VPC"
}
}

resource "aws_subnet" "My_VPC_Subnet" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"
tags = {
   Name = "My VPC Subnet"
}
}
resource "aws_subnet" "My_VPC_Subnet2" {
  vpc_id                  = aws_vpc.My_VPC.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1b"
tags = {
   Name = "My VPC Subnet"
}
}
resource "aws_internet_gateway" "My_VPC_GW" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Internet Gateway"
}
}
resource "aws_route_table" "My_VPC_route_table" {
 vpc_id = aws_vpc.My_VPC.id
 tags = {
        Name = "My VPC Route Table"
}
}

resource "aws_route" "My_VPC_internet_access" {
  route_table_id         = aws_route_table.My_VPC_route_table.id
  destination_cidr_block =  "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.My_VPC_GW.id
}

resource "aws_route_table_association" "My_VPC_association" {
  subnet_id      = aws_subnet.My_VPC_Subnet.id
  route_table_id = aws_route_table.My_VPC_route_table.id
}

resource "aws_security_group" "allow_word" {
  name        = "allow_word"
   vpc_id     = aws_vpc.My_VPC.id
ingress {

    from_port   = 3306		
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
   vpc_id     = aws_vpc.My_VPC.id
ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "database" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.My_VPC_Subnet2.id
  vpc_security_group_ids = [ aws_security_group.allow_word.id ]
  key_name = "task1-key"

  tags = {
    Name = "database"
    }
}
  resource "aws_instance" "wordpress_os" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.My_VPC_Subnet.id
  vpc_security_group_ids = [ aws_security_group.allow_http.id ]
   key_name = "task1-key"


  tags = {
    Name = "wordpress"
    }
}


