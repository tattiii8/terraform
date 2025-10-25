provider "aws" {
    region = "ap-northeast-1"
}

resource "aws_instance" "example" {
    ami         = "ami-0a71a0b9c988d5e5e"
    instance_type = "t2.micro"
}
