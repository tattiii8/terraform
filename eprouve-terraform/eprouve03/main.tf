provider "aws" {
    region = "ap-northeast-1"
}

variable "ssh_port" {
    description = "SSH port number"
    type        = number
    default     = 22
}

resource "aws_security_group" "example" {
    name        = "example-security-group"
    description = "Security group for example instance"

    ingress {
        description = "SSH"
        from_port   = var.ssh_port
        to_port     = var.ssh_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "example-security-group"
    }
}

resource "aws_instance" "example" {
    ami                    = "ami-0a71a0b9c988d5e5e"
    instance_type          = "t2.micro"
    vpc_security_group_ids = [aws_security_group.example.id]

    tags = {
        Name = "example-instance"
    }
}