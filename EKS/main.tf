#Vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks_cluster_vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets


  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/awake" = "shared"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/awake" = "shared"
    "kubernetes.io/role/elb"      = 1

  }
  private_subnet_tags = {
    "kubernetes.io/cluster/awake"    = "shared"
    "kubernetes.io/role/private_elb" = 1

  }
}

#EKS

module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "awake"
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = var.instance_types
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_view_role" {
  name = "eks-view-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_view_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/EKSViewOnlyPolicy"
  role       = aws_iam_role.eks_view_role.name
}

resource "aws_eks_access_entry" "EKS_Full_Access" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.eks_view_role.arn
}

