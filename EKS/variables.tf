# variable "vpc_cidr" {
#   description = "Vpc CIDR"
#   type        = string
# }

# variable "public_subnets" {
#   description = "public_subnets CIDR"
#   type        = list(string)
# }

# variable "private_subnets" {
#   description = "private_subnets CIDR"
#   type        = list(string)
# }

variable "instance_types" {
  description = "Node Instances"
  type        = list(string)
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}
