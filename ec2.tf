resource "tls_private_key" "worldskills-keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "worldskills-keypair" {
  key_name   = "worldskills-keypair"
  public_key = tls_private_key.worldskills-keypair.public_key_openssh
}

resource "local_file" "cicd_downloads_key" {
  filename = "./aws-keypair"
  content  = tls_private_key.worldskills-keypair.private_key_pem
}

resource "aws_security_group" "worldskills-i-sg" {
    name_prefix = "worldskills-i-sg"
    vpc_id = aws_vpc.wsi-vpc.id
}

resource "aws_security_group_rule" "ssh" {
    type = "ingress"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.worldskills-i-sg.id
}

resource "aws_security_group_rule" "https" {
    type = "ingress"
    from_port = "443"
    to_port = "443"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.worldskills-i-sg.id
}

resource "aws_security_group_rule" "http" {
    type = "ingress"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.worldskills-i-sg.id
}

resource "aws_instance" "wsi-bastion-ec2" {
    ami = "ami-02c329a4b4aba6a48"
    instance_type = "t2.micro"
    key_name = aws_key_pair.worldskills-keypair.key_name
    vpc_security_group_ids = [aws_security_group.worldskills-i-sg.id]
    subnet_id = aws_subnet.wsi-public-a.id
    associate_public_ip_address = true

    tags = {
        Name = "wsi-bastion-ec2"
    }
}