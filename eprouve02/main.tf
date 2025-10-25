provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_instance" "example" {
    ami         = "ami-0a71a0b9c988d5e5e"
    instance_type = "t2.micro"

   user_data = <<-EOF
               #!bin/bash 
               echo "Hello World" > index.html
               nohup busybox apache2 -f -p 8080 &
               EOF
    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }

}
resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
}
