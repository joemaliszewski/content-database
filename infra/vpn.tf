# Define an RDS subnet group for your RDS database.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"  # A descriptive name for your RDS subnet group.
  subnet_ids = var.subnet_ids         # The list of subnet IDs to associate with this group.

  tags = {
    Name = "My RDS Subnet Group"  # A tag for identifying this resource.
  }
}

# Define a security group for your RDS database.
resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.vpc.id  # Associate the security group with the VPC.
#   name        = "rds_allow_sql_traffic"
  # Allow incoming traffic on port 3306 (MySQL) from trusted IP addresses.
  ingress {
    from_port   = 3306  # Port for incoming traffic, 3306 for MySQL.
    to_port     = 3306  # Port for incoming traffic, matching MySQL.
    protocol    = "tcp"  # Specify the TCP protocol for MySQL.
    cidr_blocks = var.trusted_ips  # List of trusted IP addresses.
  }
}

# Define a virtual private gateway.
resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = data.aws_vpc.vpc.id  # Associate the VPN gateway with the VPC.
}

# Define a customer gateway for your VPN connection.
resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000  # BGP Autonomous System Number.
  ip_address = "82.37.202.85"  # Public IPv4 address of your VPN gateway without the subnet mask.
  type       = "ipsec.1"  # VPN connection type.
}

# Define the VPN connection.
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id  # Use the VPN gateway created earlier.
  customer_gateway_id = aws_customer_gateway.customer_gateway.id  # Use the customer gateway created earlier.
  type                = "ipsec.1"  # VPN connection type.
  static_routes_only  = true  # Use static routes for VPN.
}


# Define Network ACL rules to allow traffic from VPN to RDS subnet.
resource "aws_network_acl" "vpn_to_rds_acl" {
  vpc_id = data.aws_vpc.vpc.id  # Associate with the VPC.

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "82.37.202.85/32"
    from_port  = 3306
    to_port    = 3306
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "82.37.202.85/32"
    from_port  = 3306
    to_port    = 3306
  }
}

resource "aws_db_instance" "default" {
    allocated_storage    = 20
    storage_type         = "gp2"
    engine               = "mysql"
    engine_version       = "5.7"
    instance_class       = "db.t2.micro"
    username = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)["username"]
    password = jsondecode(data.aws_secretsmanager_secret_version.db_creds.secret_string)["password"]
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot  = false
    db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.rds_sg.id]
    identifier = "dev-rds-content-database"
    final_snapshot_identifier = "dev-rds-content-database-final-snapshot"
}


output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance."
  value       = aws_db_instance.default.endpoint
}
