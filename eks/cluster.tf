module "eks" {
  source                      = "terraform-aws-modules/eks/aws"
  version                     = "19.15.3"
  cluster_name                = "${var.project}-cluster"
  subnet_ids                  = module.vpc.private_subnets
  cluster_security_group_name = "${var.project}-sg"
  vpc_id                      = module.vpc.vpc_id
  cluster_version             = "1.24"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  create_cloudwatch_log_group             = true
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow all ingress traffic"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }


  eks_managed_node_groups = {
    test = {
      min_size     = 2
      max_size     = 2
      desired_size = 2

      use_custom_launch_template = true
      launch_template_name       = "${var.project}-template"

      cluster_security_group_name = "${var.project}-sg"


      instance_types               = ["t3.medium"]
      capacity_type                = "ON_DEMAND"
      iam_role_additional_policies = {
        additional = "arn:aws:iam::138941284341:policy/AWSLoadBalancerControllerIAMPolicy"
      }
      labels = {
        purpose     = "test"
        environment = "test"
      }
    }

  }



  # aws-auth configmap
  manage_aws_auth_configmap = true


  cluster_addons = {
    coredns = {
      preserve    = true
      most_recent = true

      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }

  }
}