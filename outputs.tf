output "account" {
  value = {
    id     = data.aws_caller_identity.current.account_id
    region = var.region
  }
  description = "A map of AWS account attributes: id, region."
}

output "cluster" {
  // NOTE: these are declared here -
  // https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest?tab=outputs
  value = {
    arn                        = module.eks.cluster_arn
    certificate_authority_data = module.eks.cluster_certificate_authority_data
    endpoint                   = module.eks.cluster_endpoint
    name                       = module.eks.cluster_name
    platform_version           = module.eks.cluster_platform_version
    status                     = module.eks.cluster_status
    oidc_issuer_url            = module.eks.cluster_oidc_issuer_url
    oidc_provider_arn          = module.eks.oidc_provider_arn
    cluster_security_group_id  = module.eks.cluster_security_group_id
    node_security_group_id     = module.eks.node_security_group_id
  }
  description = "A map of EKS cluster attributes: arn, certificate_authority_data, endpoint, name, platform_version, status, oidc_issuer_url, oidc_provider_arn, cluster_security_group_id, node_security_group_id."
}

output "vpc" {
  value = {
    // NOTE: these are declared here -
    // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
    name = data.aws_vpc.vpc.name
    id   = data.aws_vpc.vpc.id
    arn  = data.aws_vpc.vpc.arn
    cidr = data.aws_vpc.vpc.cidr_block
    azs  = data.aws_vpc.vpc.azs

    // ensure the data resource will actually hand us this
    private_subnet_cidr_blocks = data.aws_vpc.vpc.private_subnets_cidr_blocks
    private_subnet_ids         = data.aws_vpc.vpc.private_subnets

    public_subnet_cidr_blocks = data.aws_vpc.vpc.public_subnets_cidr_blocks
    public_subnet_ids         = data.aws_vpc.vpc.public_subnets
    default_security_group_id = data.aws_vpc.vpc.default_security_group_id
  }
  description = "A map of vpc attributes: name, id, cidr, azs, private_subnet_cidr_blocks, private_subnet_ids, public_subnet_cidr_blocks, public_subnet_ids, default_security_group_id."
}

output "ecr" {
  value = {
    repository_url  = module.ecr.repository_url
    repository_arn  = module.ecr.repository_arn
    repository_name = var.nuon_id
    registry_id     = module.ecr.repository_registry_id
    registry_url    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  }
  description = "A map of ECR attributes: repository_url, repository_arn, repository_name, registry_id, registry_url."
}


output "public_domain" {
  value = {
    nameservers = aws_route53_zone.public.name_servers
    name        = aws_route53_zone.public.name
    zone_id     = aws_route53_zone.public.id
  }
  description = "A map of public Route53 zone attributes: nameservers, name, zone_id."
}

output "internal_domain" {
  value = {
    nameservers = aws_route53_zone.internal.name_servers
    name        = aws_route53_zone.internal.name
    zone_id     = aws_route53_zone.internal.id
  }
  description = "A map of internal Route53 zone attributes: nameservers, name, zone_id."
}
