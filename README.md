# aws-eks-sandbox

Turnkey AWS EKS sandbox for Nuon apps.

## Usage

This module can be used via the
[aws-eks](https://github.com/nuonco/sandboxes/tree/main/aws-eks) project in
[nuonco/sandboxes](https://github.com/nuonco/sandboxes).

```hcl
resource "nuon_app" "my_eks_app" {
  name = "my_eks_app"
}

resource "nuon_app_sandbox" "main" {
  app_id            = nuon_app.my_eks_app.id
  terraform_version = "v1.7.5"
  public_repo = {
    repo      = "nuonco/sandboxes"
    branch    = "main"
    directory = "aws-eks"
  }
}

resource "nuon_app_runner" "main" {
  app_id      = nuon_app.my_eks_app.id
  runner_type = "aws-eks"
}
```
