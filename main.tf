provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "ionginx_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "ionginx-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = 3
  vpc_id            = aws_vpc.ionginx_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ionginx_vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = 3
  vpc_id            = aws_vpc.ionginx_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ionginx_vpc.cidr_block, 8, count.index + 3)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ionginx_vpc.id

  tags = {
    Name = "ionginx-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ionginx_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_association" {
  count          = 3
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "ionginx-nat"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ionginx_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_association" {
  count          = 3
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_launch_configuration" "nginx" {
  name          = "nginx-lc"
  image_id      = "ami-0a91cd140a1fc148a" # Ubuntu AMI ID
  instance_type = "t2.micro"
  key_name      = "" # no key pair for SSH

  lifecycle {
    create_before_destroy = true
  }

  user_data = file("${path.module}/userdata.sh")

  associate_public_ip_address = false

  security_groups = [aws_security_group.private_sg.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = aws_subnet.private_subnet[*].id
  launch_configuration = aws_launch_configuration.nginx.id
  health_check_type    = "EC2"

  tag {
    key                 = "Name"
    value               = "nginx-asg"
    propagate_at_launch = true
  }

  force_delete = true
}

resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Allow only HTTP traffic"
  vpc_id      = aws_vpc.ionginx_vpc.id

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

  tags = {
    Name = "private-sg"
  }
}

resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_route53_record" "nginx" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "nginx.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nat.public_ip]
}
