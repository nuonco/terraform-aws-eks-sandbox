# noqa
internal_root_domain = "internal.inl4kswfghtbjvygxnuynkxohz.nuon.run"
public_root_domain = "api.inl4kswfghtbjvygxnuynkxohz.nuon.run"
nuon_id = "inl4kswfghtbjvygxnuynkxohz"
region  = "us-east-2"
# assume_role_arn  = "arn:aws:iam::949309607565:role/nuon-demo-install-access"
# assume_role_arn  = "arn:aws:iam::949309607565:role/nuon-aws-eks-install-access-003" # This needs to be set for use from our services but should not be when running locally.
runner_install_role = "arn:aws:iam::949309607565:role/nuon-aws-eks-install-access-003"

tags = {
  nuon_id              = "org2p22dpzwvwrrwna8laa6o8k"
  nuon_install_id      = "inl4kswfghtbjvygxnuynkxohz"
  nuon_app_id          = "appnjs4w7n1ozkhllblcjb8crs"
  nuon_sandbox_name    = "aws-eks"
}
waypoint_odr_namespace            = "inl4kswfghtbjvygxnuynkxohz"
waypoint_odr_service_account_name = "runner-inl4kswfghtbjvygxnuynkxohz"
