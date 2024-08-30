provider "kubernetes" {
  host                   = data.aws_eks_cluster.awake.endpoint
  token                  = data.aws_eks_cluster_auth.awake.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.awake.certificate_authority[0].data)
}

