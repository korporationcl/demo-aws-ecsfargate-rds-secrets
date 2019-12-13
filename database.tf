locals {
  # This needs to be changed ASAP in production or use a different strategy to keep this secure (KMS).
  db_name     = "demo"
  db_user     = "demo"
  db_password = "a6j6TMHBAHD68FWDVtXYWeeRUxgK"
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = module.vpc.public_subnets
  tags       = var.tags
}

resource "aws_db_instance" "database" {
  allocated_storage    = 10    # This should be changed in prod and beyond
  storage_encrypted    = false # This should be enabled in prod
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.4"
  instance_class       = var.instance_types["db"]
  name                 = local.db_name
  username             = local.db_user
  password             = local.db_password
  multi_az             = var.db_multiaz
  db_subnet_group_name = aws_db_subnet_group.default.name
}

resource "aws_security_group" "database" {
  vpc_id = module.vpc.vpc_id
  tags   = var.tags

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      aws_security_group.ecs.id,
    ]
  }
}

# This should cover the item for updating PostgreSQL configuration
resource "aws_db_parameter_group" "config" {
  name   = "pg-conf"
  family = "postgres11.4"

  parameter {
    name  = "timezone"
    value = "GMT"
  }
}

# Getting the output to point the application to this endpoint
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.database.address
}
