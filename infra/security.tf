# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "my-rds-subnet-group"
#   subnet_ids = var.subnet_ids

#   tags = {
#     Name = "My RDS Subnet Group"
#   }
# }

# resource "aws_security_group" "rds_sg" {
#   vpc_id = data.aws_vpc.vpc.id
#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = var.trusted_ips
#   }
# }
