resource "aws_ecr_repository" "web" {
  name                 = "ipssi-web"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "main" {
  name = "ipssi-ecs"
}

resource "aws_security_group" "ecs" {
  name        = "ipssi-ecs-sg"
  description = "Security group for IPSSI ECS Fargate"
  vpc_id      = "vpc-0eb98b57b7794a4ea"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "web" {
  family                   = "ipssi-web"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::367496797440:role/LabRole"

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "367496797440.dkr.ecr.us-east-1.amazonaws.com/ipssi-web:v1"
      essential = true

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}




resource "aws_ecs_service" "web" {
  name            = "web-svc"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
      "subnet-0e3836e33d1269052",
      "subnet-0c264176d88b24196"
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = true
  }
}
