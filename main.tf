terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "eu-west-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

# 1. VPC (Red Privada)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "vpc-laboratorio" }
}

# 2. Subred Pública
resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "subred-publica" }
}

# 3. Subred Privada
resource "aws_subnet" "privada" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = { Name = "subred-privada" }
}

# 4. Cortafuegos / Security Group
resource "aws_security_group" "web_sg" {
  name        = "permitir-http-ssh"
  description = "Permite acceso por puerto 80 y 22"
  vpc_id      = aws_vpc.main.id

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
}

# 5. Instancia EC2 dentro de la subred pública
resource "aws_instance" "servidor_web" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.publica.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = { Name = "Servidor-Web-Lab" }
}
