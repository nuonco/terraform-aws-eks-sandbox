# m1 aws-eks-sandbox

Turnkey AWS EKS sandbox for Nuon apps.

## Usage

## Components

### Managed Here

1. EKS
2. ECR

### Helm

1. EBS CSI
2. Metrics Server

### Manged with details from cloduformation

1. VPC
2. DNS

### Components that may be moved to components

1. External DNS
2. Cert Manager
3. ALB Ingress
4. Nginx Ingress

## Notes

### Runner Role

This is external now. We now just create an access entry for it.
