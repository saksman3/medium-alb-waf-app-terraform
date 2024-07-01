# resource "aws_docdb_cluster" "main" {
#   cluster_identifier = "${local.name}-docdb-cluster"
#   master_username    = "root" #replace with your desired username
#   master_password    = "example123" #replace with your desired password
#   db_subnet_group_name = aws_docdb_subnet_group.main.name
#   vpc_security_group_ids = [aws_security_group.docdb.id]
# }

# resource "aws_docdb_cluster_instance" "instance" {
#   count              = 2
#   identifier         = "${local.name}-docdb-instance-${count.index}"
#   cluster_identifier = aws_docdb_cluster.main.id
#   instance_class     = "db.r5.large"
# }

# resource "aws_docdb_subnet_group" "main" {
#   name       = "${local.name}-docdb-subnet-group"
#   subnet_ids = aws_subnet.private_db_subnet[*].id
# }
