/*
    AWS Resource Configuration
*/

# Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Demo-VPC"
  }
}

# Create Public Subnets
resource "aws_subnet" "alb-subnet1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "ALB-Subnet1"
  }
}

resource "aws_subnet" "alb-subnet2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "ALB-Subnet2"
  }
}

# Create Application Private Subnets
resource "aws_subnet" "app-subnet1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "APP-Subnet1"
  }
}

resource "aws_subnet" "app-subnet2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "APP-Subnet2"
  }
}

# Create Database Private Subnets
resource "aws_subnet" "db-subnet1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "DB-Subnet1"
  }
}

resource "aws_subnet" "db-subnet2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "DB-Subnet2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "Demo-IGW"
  }
}

# Create NAT Gateway
## EIP
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

## NAT GATEWAY
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = aws_subnet.alb-subnet1.id
  tags = {
    Name = "nat-gw"
  }
}

# Create public route table
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public_route"
  }
}

# Create private route table
resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "Private_route"
  }
}

# Subnet association with public route table
resource "aws_route_table_association" "route_associate1" {
  subnet_id      = aws_subnet.alb-subnet1.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "route_associate2" {
  subnet_id      = aws_subnet.alb-subnet2.id
  route_table_id = aws_route_table.public-route.id
}

# Subnet association with private route table
resource "aws_route_table_association" "route_associate3" {
  subnet_id      = aws_subnet.app-subnet1.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "route_associate4" {
  subnet_id      = aws_subnet.app-subnet2.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "route_associate5" {
  subnet_id      = aws_subnet.db-subnet1.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "route_associate6" {
  subnet_id      = aws_subnet.db-subnet2.id
  route_table_id = aws_route_table.private-route.id
}

# Create Public Security Group
resource "aws_security_group" "public-sg" {
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
  name        = "ALB-SG"

  ingress {
    description = "HTTP Traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS Traffic"
    from_port   = 443
    to_port     = 443
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
    Name = "ALB-SG"
  }
}

# Create Application Security Group
resource "aws_security_group" "app-sg" {
  description = "Allow inbound traffic from ALB"
  vpc_id      = aws_vpc.my-vpc.id
  name        = "APP-SG"

  ingress {
    description     = "Allow traffic from web layer"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "App-SG"
  }
}

# Create Database Security Groups
resource "aws_security_group" "db-sg" {
  description = "Allow inbound traffic from Application Server Only"
  vpc_id      = aws_vpc.my-vpc.id
  name        = "DB-SG"

  ingress {
    description     = "Allow traffic from application layer"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB-SG"
  }
}

# launch Template of Autoscaling group
resource "aws_launch_template" "launch_template" {
  name          = "DEMO-Template"
  image_id      = "ami-id-name"
  instance_type = "t2.micro"
  key_name      = "demokey" # key pair need to be available on AWS

  vpc_security_group_ids = [aws_security_group.app-sg.id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type = "gp2"
      volume_size = 20
      kms_key_id  = "kms-id-arn"
      encrypted   = true
    }
  }
}

# Autoscaling group
resource "aws_autoscaling_group" "asg" {
  name                      = "DEMO-ASG"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.app-subnet1.id, aws_subnet.app-subnet2.id]
  health_check_grace_period = 900
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
  target_group_arns = [
    aws_lb_target_group.alb_tg.arn
  ]
}


# Application load balancer
resource "aws_lb" "alb" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public-sg.id]
  subnets            = [aws_subnet.alb-subnet1.id, aws_subnet.alb-subnet2.id]
}

# Application HTTPS Target Group
resource "aws_lb_target_group" "alb_tg" {
  name     = "ALB-TG"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.my-vpc.id

  health_check {
    path                = "/_health_check"
    protocol            = "HTTPS"
    matcher             = "200-299"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

# Application Load Balancer Listeners
resource "aws_lb_listener" "alb_listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "alb_listener_443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = "arn:aws:acm:us-east-1:xxxxxxxxxx:certificate/445656e-07854-46g5-4f64-d5656af5f21"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}



# RDS Subnet Group association
resource "aws_db_subnet_group" "rds_subnet" {
  name       = "main"
  subnet_ids = [aws_subnet.db-subnet1.id, aws_subnet.db-subnet2.id]

  tags = {
    Name = "RDS subnet group"
  }
}

# Create RDS Instance
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet.id
  engine                 = "PostgreSQL"
  engine_version         = "11.10"
  instance_class         = "db.t2.micro"
  multi_az               = true
  name                   = "db1"
  username               = "user"
  password               = "pass"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db-sg.id]
}
