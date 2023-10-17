data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "content-database"
}

data "aws_secretsmanager_secret_version" "trusted_ip" {
  secret_id = "joes_ip"
}

data "aws_vpc" "vpc" {
  default = true
}
