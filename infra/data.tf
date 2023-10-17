data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "content-database"
}

data "aws_vpc" "vpc" {
  default = true
}
