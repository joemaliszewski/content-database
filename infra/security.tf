# Define a security group that allows access only from a list of IP addresses.
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [jsondecode(data.aws_secretsmanager_secret_version.trusted_ip.secret_string)["joes_ip"]]
  }
}
