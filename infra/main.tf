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