# modules/regional/modules/qdrant/main.tf
resource "aws_ecs_cluster" "qdrant" {
  name = "${var.organisation}-qdrant-cluster-${var.region}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "qdrant" {
  family                   = "${var.organisation}-qdrant-task-${var.region}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "5120"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "qdrant-container"
      image = "qdrant/qdrant:latest"
      portMappings = [
        {
          containerPort = 6333
          hostPort      = 6333
          protocol      = "tcp"
        },
        {
          containerPort = 6334
          hostPort      = 6334
          protocol      = "tcp"
        },
        {
          containerPort = 6335
          hostPort      = 6335
          protocol      = "tcp"
        }
      ]
      essential = true
      command   = var.region == "eu-west-2" ? ["./qdrant", "--uri", "http://${var.service_discovery_name}.${var.namespace_name}:6335"] : ["./qdrant", "--bootstrap", "http://${var.primary_service_discovery_name}.${var.primary_namespace_name}:6335"]
      environment = concat([
        {
          name  = "QDRANT__CLUSTER__ENABLED"
          value = "true"
        },
        {
          name  = "QDRANT__CLUSTER__P2P__PORT"
          value = "6335"
        }
      ], var.region != "eu-west-2" ? [
        {
          name  = "QDRANT__STORAGE__NODE_TYPE"
          value = "Listener"
        }
      ] : [])
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/qdrant-task"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-create-group"  = "true"
          "mode"                  = "non-blocking"
          "max-buffer-size"       = "25m"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "qdrant" {
  name            = "${var.organisation}-qdrant-service-${var.region}"
  cluster         = aws_ecs_cluster.qdrant.id
  task_definition = aws_ecs_task_definition.qdrant.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn   = var.service_discovery_service_arn

  }
}

