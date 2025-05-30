#----------------------------------------
# EC2インスタンスの作成
#----------------------------------------
resource "aws_instance" "sample_web_server" {
  ami                    = "ami-0c1638aa346a43fe8" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.sample_subnet.id
  vpc_security_group_ids = [aws_security_group.sample_sg.id]
  user_data = <<EOF
#! /bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
}