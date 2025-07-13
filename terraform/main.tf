terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group
resource "aws_security_group" "pokeapi_sg" {
  name        = "pokeapi-security-group"
  description = "Security group for PokeAPI instances"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask API"
    from_port   = 5000
    to_port     = 5000
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
    Name = "pokeapi-security-group"
  }
}

# Key Pair
resource "aws_key_pair" "pokeapi_key" {
  key_name   = "pokeapi-key"
  public_key = file(var.public_key_path)
}

# Backend EC2 Instance
resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.pokeapi_key.key_name
  vpc_security_group_ids = [aws_security_group.pokeapi_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker git
    systemctl start docker
    systemctl enable docker
    usermod -a -G docker ec2-user
  EOF
  )

  tags = {
    Name = "PokeAPI-Backend"
    Type = "Backend"
  }
}

# Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.pokeapi_key.key_name
  vpc_security_group_ids = [aws_security_group.pokeapi_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip git
    pip3 install --upgrade pip
  EOF
  )

  tags = {
    Name = "PokeAPI-Frontend"
    Type = "Frontend"
  }
}