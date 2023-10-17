
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "172.31.48.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "172.31.49.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "172.31.50.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_3"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  tags = {
    Name = "My RDS Subnet Group"
  }
}
