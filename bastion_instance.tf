data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_instance" "bastion" {
  #checkov:skip=CKV_AWS_135:This is an EC2 instance for testing purposes
  #checkov:skip=CKV_AWS_126:This is an EC2 instance for testing purposes
  #checkov:skip=CKV_AWS_8:This is an EC2 instance for testing purposes
  ami                  = data.aws_ami.amazon_linux_2.id
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.private_a.id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  security_groups      = [aws_security_group.bastion_sg.id]

  metadata_options {
    http_endpoint          = "disabled"
    http_protocol_ipv6     = "disabled"
    instance_metadata_tags = "disabled"
  }

  tags = {
    Name = "bastion"
  }
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH and SSM traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    description = "For testing purposes"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    description = "For testing purposes"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "For testing purposes"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
