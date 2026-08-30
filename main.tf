terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
  }
}

# 1. RED PRINCIPAL (VPC)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "lab-vpc-prod"
  }
}

# 2. SUBREDES
# Subred Publica
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-alb"
  }
}

# Subred Privada Web
resource "aws_subnet" "web_private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-web"
  }
}

# Subred Privada Base de Datos
resource "aws_subnet" "db_private_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "private-subnet-db"
  }
}

# 3. INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# 4. TABLAS DE ENRUTAMIENTO
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. SECURITY GROUPS (Diseño Multi-Capa)
# SG simulando el punto de entrada (Frontend)
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Simulacion SG del balanceador"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG Servidor Web (Solo acepta conexiones del SG Frontend)
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Permitir trafico unicamente desde el Frontend"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG Base de Datos (Solo acepta conexiones del SG Web)
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Permitir trafico solo desde el servidor web"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. INSTANCIAS (EC2 Privadas)
resource "aws_instance" "web_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.web_private_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-ec2-private"
  }
}

resource "aws_instance" "db_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.db_private_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "database-server-ec2-private"
  }
}

# 7. Network ACL (NACL) para proteger la Subred Privada de BBDD
resource "aws_network_acl" "db_nacl" {
  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [aws_subnet.db_private_subnet.id]

  ingress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 5432
    to_port    = 5432
    protocol   = "tcp"
  }

  egress {
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.2.0/24"
    from_port  = 1024
    to_port    = 65535
    protocol   = "tcp"
  }

  tags = {
    Name = "db-private-nacl"
  }
}
