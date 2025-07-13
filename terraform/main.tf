<<<<<<< HEAD
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

# IAM Role for EC2 instances
resource "aws_iam_role" "pokeapi_role" {
  name = "pokeapi-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "pokeapi_dynamodb_policy" {
  name        = "pokeapi-dynamodb-policy"
  description = "Policy for DynamoDB access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/pokemon-collection"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "pokeapi_policy_attachment" {
  role       = aws_iam_role.pokeapi_role.name
  policy_arn = aws_iam_policy.pokeapi_dynamodb_policy.arn
}

# Instance profile
resource "aws_iam_instance_profile" "pokeapi_profile" {
  name = "pokeapi-instance-profile"
  role = aws_iam_role.pokeapi_role.name
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
  iam_instance_profile   = aws_iam_instance_profile.pokeapi_profile.name

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
=======
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

# IAM Role for EC2 instances
resource "aws_iam_role" "pokeapi_role" {
  name = "pokeapi-ec2-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        "Effect": "Allow",
        "Action": "iam:CreateRole",
        "Resource": "*"
      }
    ]
  })
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "pokeapi_dynamodb_policy" {
  name        = "pokeapi-dynamodb-policy"
  description = "Policy for DynamoDB access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/pokemon-collection"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "pokeapi_policy_attachment" {
  role       = aws_iam_role.pokeapi_role.name
  policy_arn = aws_iam_policy.pokeapi_dynamodb_policy.arn
}

# Instance profile
resource "aws_iam_instance_profile" "pokeapi_profile" {
  name = "pokeapi-instance-profile"
  role = aws_iam_role.pokeapi_role.name
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
  iam_instance_profile   = aws_iam_instance_profile.pokeapi_profile.name

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
>>>>>>> 65e20a5 (Initial commit)
}