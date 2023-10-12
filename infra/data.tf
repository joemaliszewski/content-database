data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "content-database"
}


data "aws_subnet" "existing_subnets" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

data "aws_vpc" "vpc" {
  default = true
}