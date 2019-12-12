data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"

  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_user",
      "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_password",
      "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_host",
      "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:db_name",
    ]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ECSRoleTask"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
