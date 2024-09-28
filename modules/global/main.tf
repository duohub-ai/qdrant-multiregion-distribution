module "iam" {
  source = "./modules/iam"

  role_name                   = "${var.organisation}_ecs_task_role"
  policy_name                 = "${var.organisation}_ecs_task_policy"
}
