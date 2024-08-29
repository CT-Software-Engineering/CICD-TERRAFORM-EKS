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

# data "aws_eks_cluster" "awake {
#   name = module.eks.cluster_name
# }

data "aws_eks_cluster_auth" "awake" {
  name = module.eks.cluster_name
}

# Install the EKS Pod Identity Agent add-on
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.awake
  addon_name   = "pod-identity"
}





