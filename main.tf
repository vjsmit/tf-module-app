##security group

resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.sg_subnets_cidr
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.allow_ssh_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.component}-${var.env}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_launch_template" "main" {
  name = "${var.component}-${var.env}"
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  image_id               = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [ aws_security_group.main.id ]

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ Name = "${var.component}-${var.env}", Monitor = "true" }, var.tags)
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    env       = var.env
    component = var.component
  }))
}

resource "aws_autoscaling_group" "main" {
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns = [ aws_lb_target_group.main.arn ]

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }
}

#dns record

resource "aws_route53_record" "main" {
  zone_id = "Z0478111B3O54DLF4LSS"
  name    = "${var.component}-${var.env}"
  type    = "CNAME"
  ttl     = 30
  records = [var.lb_dns_name]
}

