resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "aws_driver"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aws_driver"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "aws_driver_public_route_table"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.vpc.id
  name   = "my_security_group"
  ingress {
    from_port = 3306
    protocol  = "tcp"
    to_port   = 3306
  }
  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
  }
}

resource "aws_rds_cluster_parameter_group" "this" {
  name   = "aws-driver"
  family = "aurora-mysql5.7"

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "immediate"
  }
}

resource "aws_rds_cluster" "this" {
  cluster_identifier              = "my-aurora-cluster"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.10.2"
  availability_zones              = ["ap-northeast-1a"]
  master_username                 = local.master_username
  master_password                 = local.master_password
  port                            = 3306
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  skip_final_snapshot = true
  apply_immediately   = true

}

resource "aws_db_parameter_group" "this" {
  name   = "aws-driver"
  family = "aurora-mysql5.7"
}

resource "aws_rds_cluster_instance" "this" {
  count              = 2
  identifier         = "aurora-cluster-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id

  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version
  instance_class = "db.t3.small"

  db_subnet_group_name    = aws_rds_cluster.this.db_subnet_group_name
  db_parameter_group_name = aws_db_parameter_group.this.name

  publicly_accessible = true

}