locals {
  # private_subnet_ids = split(",", var.private_subnet_ids)
  # public_subnet_ids  = split(",", var.public_subnet_ids)
  tags = merge(
    var.tags,
    {
      "nuon.co/id" = var.nuon_id
    },
    var.additional_tags,
  )
}

#
# from cloudformation
#
variable "vpc_id" {
  type        = string
  description = "The ID of the AWS VPC to provision the sandbox in."
}

variable "runner_iam_role_arn" {
  type        = string
  description = "The role that is used by the runner, and should be granted access to the cluster."
}

# variable "public_subnet_ids" {
#   type        = string
#   description = "Comma separated list of public subnet ds."
#   default     = ""
# }

# variable "private_subnet_ids" {
#   type        = string
#   description = "Comma separated list of private subnet ids."
#   default     = ""
# }

#
# install inputs
#
variable "cluster_version" {
  type        = string
  description = "The Kubernetes version to use for the EKS cluster."
  default     = "1.32"
}


variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster. If not provided, the install ID will be used by default."
  default     = ""
}

variable "min_size" {
  type        = number
  default     = 2
  description = "The minimum number of nodes in the managed node group."
}

variable "max_size" {
  type        = number
  default     = 5
  description = "The maximum number of nodes in the managed node group."
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "The desired number of nodes in the managed node group."
}

variable "default_instance_type" {
  type        = string
  default     = "t3a.medium"
  description = "The EC2 instance type to use for the EKS cluster's default node group."
}

variable "admin_access_role" {
  type        = string
  default     = ""
  description = "A role that be granted access cluster AmazonEKSAdminPolicy and AmazonEKSClusterAdminPolicy access."
}

variable "additional_tags" {
  type        = map(any)
  description = "Extra tags to append to the default tags that will be added to install resources."
  default     = {}
}

#
# set by nuon
#
variable "nuon_id" {
  type        = string
  description = "The nuon id for this install. Used for naming purposes."
}

variable "region" {
  type        = string
  description = "The region to launch the cluster in."
}

# DNS
variable "public_root_domain" {
  type        = string
  description = "The public root domain."
}

# NOTE: if you would like to create an internal load balancer, with TLS, you will have to use the public domain.
variable "internal_root_domain" {
  type        = string
  description = "The internal root domain."
}

variable "tags" {
  type        = map(any)
  description = "List of custom tags to add to the install resources. Used for taxonomic purposes."
}
