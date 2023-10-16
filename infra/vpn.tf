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
  ip_address = "82.37.202.85/32"  # Public IP address of your VPN gateway.
  type       = "ipsec.1"  # VPN connection type.
}

# Define the VPN connection.
resource "aws_vpn_connection" "main" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id  # Use the VPN gateway created earlier.
  customer_gateway_id = aws_customer_gateway.customer_gateway.id  # Use the customer gateway created earlier.
  type                = "ipsec.1"  # VPN connection type.
  static_routes_only  = true  # Use static routes for VPN.
}

# Allow incoming traffic on port 3306 (MySQL) from the VPN connection.
resource "aws_security_group_rule" "vpn_to_rds" {
  type        = "ingress"  # Allow incoming traffic.
  from_port   = 3306  # Port for incoming traffic, 3306 for MySQL.
  to_port     = 3306  # Port for incoming traffic, matching MySQL.
  protocol    = "tcp"  # Specify the TCP protocol for MySQL.
  cidr_blocks = ["82.37.202.85/32"]  # Trusted IP address for VPN connection.
  security_group_id = aws_security_group.rds_sg.id  # Use the existing security group ID.
}

# Define a route in the VPC route table to route traffic to your RDS subnet through the VPN connection.
resource "aws_route" "vpn_to_rds_route" {
  route_table_id = data.aws_vpc.vpc.default_route_table_id  # Use the default route table ID of your VPC.

  # Ensure that the route depends on the creation of the RDS subnet group.
  depends_on = [aws_db_subnet_group.rds_subnet_group]

  # Dynamically retrieve the CIDR blocks from the subnets specified in the RDS subnet group.
  dynamic "destination_cidr_block" {
    for_each = aws_db_subnet_group.rds_subnet_group.subnet_ids
    content {
      value = aws_subnet[destination_cidr_block.value].cidr_block
    }
  }
}

# Define Network ACL rules (if applicable) to allow traffic from VPN to RDS subnet.
# Example: Allow incoming traffic on port 3306 (MySQL) from the VPN connection.
data "aws_network_acl" "default" {
  default = true  # Use the default Network ACL.
  vpc_id  = data.aws_vpc.vpc.id  # Associate with the VPC.
}

# Define a Network ACL rule to allow MySQL traffic from the VPN connection.
resource "aws_network_acl_rule" "vpn_to_rds_acl" {
  rule_number   = 100  # Unique identifier, can be any unique number.
  rule_action   = "allow"  # Allow incoming traffic.
  protocol      = "6"  # TCP protocol.
  from_port     = 3306  # Port for incoming traffic, 3306 for MySQL.
  to_port       = 3306  # Port for incoming traffic, matching MySQL.
  cidr_block    = "82.37.202.85/32"  # Trusted IP address for VPN connection.
  network_acl_id = data.aws_network_acl.default.id  # Use the default Network ACL ID.
}
