# Reference the default VPC
data "aws_vpc" "vpc" {
  default = true
}

# Fetch details of the three existing subnets using their IDs
data "aws_subnet" "existing_subnet_1a" {
  id = "subnet-0c5e69f23789eba09"
}

data "aws_subnet" "existing_subnet_1b" {
  id = "subnet-098916efb62b51d2e"
}

data "aws_subnet" "existing_subnet_1c" {
  id = "subnet-0e4940b45ad301e65"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    data.aws_subnet.existing_subnet_1a.id,
    data.aws_subnet.existing_subnet_1b.id,
    data.aws_subnet.existing_subnet_1c.id
  ]
}

resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.trusted_ips
  }
}

resource "aws_db_instance" "default" {
    allocated_storage    = 20
    storage_type         = "gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    username             = "vinegar"
    password             = "aeec33!ef"
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = true
    db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    tags = {
    Name = "main-rds-instance"
    }
}

output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.default.endpoint
}
