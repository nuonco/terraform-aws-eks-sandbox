locals {
  install_name   = (var.install_name != "" ? var.install_name : var.cluster_name)
  install_region = var.region
  tags = merge(
    var.tags,
    { nuon_id = var.nuon_id },
    var.additional_tags,
  )
}

variable "install_name" {
  type        = string
  description = "The name of this install. Will be used for the EKS cluster, various tags, and other resources."
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster. Will use the install ID by default."
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "The Kubernetes version to use for the EKS cluster."
  default     = "1.28"
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

variable "admin_access_role_arn" {
  description = "Optional role to provide admin access to the cluster."
  type        = string
  default     = ""
}

variable "additional_tags" {
  type        = map(any)
  description = "Extra tags to append to the default tags that will be added to install resources."
  default     = {}
}

# Automatically set by Nuon when provisioned.

variable "nuon_id" {
  type        = string
  description = "The nuon id for this install. Used for naming purposes."
}

variable "region" {
  type        = string
  description = "The region to launch the cluster in"
}

variable "assume_role_arn" {
  type        = string
  description = "The role arn to assume during provisioning of this sandbox."
}

variable "external_access_role_arns" {
  type        = list(string)
  description = "Roles for external access to the cluster."
}

variable "waypoint_odr_namespace" {
  type        = string
  description = "Namespace that the ODR iam role's service account presides."
}

variable "waypoint_odr_service_account_name" {
  type        = string
  description = "Service account that the ODR iam role should be assumable from."
}

variable "public_root_domain" {
  type        = string
  description = "public root domain."
}

// NOTE: if you would like to create an internal load balancer, with TLS, you will have to use the public domain.
variable "internal_root_domain" {
  type        = string
  description = "internal root domain."
}

variable "tags" {
  type        = map(any)
  description = "List of custom tags to add to the install resources. Used for taxonomic purposes."
}
