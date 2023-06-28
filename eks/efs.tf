resource "aws_efs_file_system" "eks" {
  creation_token = "${var.project}-volume"
  tags           = merge(tomap({ "Name" = "${var.project}-volume" }), local.tags)
}

resource "aws_efs_mount_target" "eks" {
  count           = length(module.vpc.private_subnets)
  subnet_id       = module.vpc.private_subnets[count.index]
  file_system_id  = aws_efs_file_system.eks.id
  security_groups = [module.eks.cluster_security_group_id, aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = "${var.project}-sg"
  description = "Allow NFS traffic for EFS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}