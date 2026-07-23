data "aws_vpcs" "all" {} // read all the VPC's details from the aws account.

// fetch all VPC's in aws account
data "aws_vpc" "details" {
  for_each = toset(data.aws_vpcs.all.ids)
  id       = each.value
}

// scoped data to select the subnet's of the selected VPC.
data "aws_subnets" "selected_vpc" {
  filter {
    name   = "vpc-id"
    values = [var.aws_vpc_id]
  }
}

// fetch details of selected VPC's subnets.
data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.selected_vpc.ids)
  id       = each.value
}

// security group for CubeAPM EC2 instance.
resource "aws_security_group" "security_group" {
  name        = "security-group"
  description = "Allow UI, metrics/logs, and MCP access from VPC"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Cubeapm-UI"
    from_port       = 3125
    to_port         = 3125
    protocol        = "tcp"
    cidr_blocks     = !var.create_alb && var.existing_alb_security_group_id == "" ? [var.aws_vpc_cidr] : []
    security_groups = var.create_alb ? [aws_security_group.alb[0].id] : (var.existing_alb_security_group_id != "" ? [var.existing_alb_security_group_id] : [])
  }

  ingress {
    description = "Metrics and logs"
    from_port   = 3130
    to_port     = 3130
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    description = "MCP"
    from_port   = 3140
    to_port     = 3140
    protocol    = "tcp"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cubeapm-security-group"
  }
}

resource "aws_security_group" "alb" {
  count       = var.create_alb ? 1 : 0
  name        = "cubeapm-alb-sg"
  description = "ALB security group"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound to targets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cubeapm-alb-sg"
  }
}

resource "aws_lb" "aws_application_loadbalancer" {
  count              = var.create_alb ? 1 : 0
  name               = "cubeapm-alb"
  internal           = var.load_balancer_internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.lb_subnet_ids
  idle_timeout       = 60

  tags = {
    Name = "cubeapm-alb"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "cubeapm-tg"
  port        = 3125
  protocol    = "HTTP"
  target_type = "instance" // default value: instance
  vpc_id      = var.aws_vpc_id

  load_balancing_algorithm_type = "round_robin"

  deregistration_delay = 300
  #   load_balancing_cross_zone_enabled = false

  target_group_health {
    unhealthy_state_routing {
      minimum_healthy_targets_count = "1"
    }
  }

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags = {
    Name = "cubeapm-tg"
  }
}

resource "aws_lb_target_group_attachment" "cubeapm-tg-attachment" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.cubeapm_instance.id
  port             = 3125
}

resource "aws_lb_listener" "https" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.aws_application_loadbalancer[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.aws_application_loadbalancer[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "cubeapm" {
  count        = var.create_alb ? 0 : 1
  listener_arn = var.existing_alb_listener_arn
  priority     = var.alb_listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = var.cubeapm_host_header
    }
  }
}
