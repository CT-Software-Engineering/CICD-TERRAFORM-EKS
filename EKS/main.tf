# VPC Module
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "eks_cluster_vpc"
#   cidr = var.vpc_cidr

#   azs             = data.aws_availability_zones.azs.names
#   public_subnets  = var.public_subnets
#   private_subnets = var.private_subnets

#   enable_dns_hostnames = true
#   enable_nat_gateway   = true
#   single_nat_gateway   = true

#   tags = {
#     "kubernetes.io/cluster/awake" = "shared"
#   }
#   public_subnet_tags = {
#     "kubernetes.io/cluster/awake" = "shared"
#     "kubernetes.io/role/elb"      = "1"
#   }
#   private_subnet_tags = {
#     "kubernetes.io/cluster/awake"    = "shared"
#     "kubernetes.io/role/private_elb" = "1"
#   }
# }

# EKS Module
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = "awake"
  cluster_version                = "1.30"
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnet_ids

  eks_managed_node_groups = {
    nodes = {
      min_size       = 1
      max_size       = 3
      desired_size   = 1
      instance_types = var.instance_types
    }
  }
  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}

# Fetch EKS Cluster Information
data "aws_eks_cluster" "awake" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "awake" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

# IAM Role for Jenkins with EKS Policies Attached
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach policies to the IAM Role (full EKS access)
resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_access" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Kubernetes ClusterRoleBinding for Jenkins
resource "kubernetes_cluster_role_binding" "jenkins_cluster_admin" {
  metadata {
    name = "jenkins-cluster-admin"
  }

  subject {
    kind      = "User"
    name      = aws_iam_role.jenkins_role.arn
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    "mapRoles" = <<EOF
- rolearn: arn:aws:iam::851725178273:role/jenkins-role
  username: jenkins
  groups:
    - system:masters
EOF
  }
}
