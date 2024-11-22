#!/bin/sh

set -u
set -o pipefail


echo "executing error-destroy script"
echo
echo '     region: '$AWS_REGION
echo '    profile: '$AWS_PROFILE
echo ' install id: '$NUON_INSTALL_ID
echo


echo "ensuring AWS is setup"
aws sts get-caller-identity > /dev/null

echo "looking for NAT Gateways"
NAT_GATEWAYS=$(aws ec2 describe-nat-gateways --filter Name=tag:Name,Values=$NUON_INSTALL_ID*)
echo $NAT_GATEWAYS | jq -r '.NatGateways[].NatGatewayId' | while read -r nat_gateway_id; do
  echo "deleting NAT Gateway "$nat_gateway_id
  aws ec2 delete-nat-gateway --nat-gateway-id $nat_gateway_id
done

echo "looking for Load Balancers"
NLBS=$(aws elbv2 describe-load-balancers | jq '.LoadBalancers')
echo $NLBS | jq -r '.[].LoadBalancerArn' | while read -r lb_arn; do
  echo $lb_arn
  tag_values=$(aws elbv2 describe-tags --resource-arn $lb_arn | jq -r '.TagDescriptions[].Tags.[].Value')
  if [[ $tag_values == *"$NUON_INSTALL_ID"*  ]]; then
    echo "deleting load balancer "$lb_arn
    aws elbv2 delete-load-balancer --load-balancer-arn $lb_arn
  fi
done

echo "looking for ENIs which were orphaned by vpc-cni plugin"
ENIS=$(aws ec2 \
  describe-network-interfaces \
  --filters Name=tag:cluster.k8s.amazonaws.com/name,Values=$NUON_INSTALL_ID)

echo $ENIS | jq -r '.NetworkInterfaces[].NetworkInterfaceId' | while read -r eni_id ; do
  echo "deleting ENI $eni_id"
  aws ec2 delete-network-interface --network-interface-id=$eni_id
done

echo "looking loadbalancer security groups..."
SGS=$(aws ec2 \
  describe-security-groups \
  --filters Name=tag:elbv2.k8s.aws/cluster,Values=$NUON_INSTALL_ID)

echo $SGS | jq -r '.SecurityGroups[].GroupId' | while read -r sg_id ; do
  echo "deleting security group $sg_id"
  aws ec2 delete-security-group --group-id=$sg_id
done

echo "looking for nuon security groups..."
SGS=$(aws ec2 \
  describe-security-groups \
  --filters Name=tag:nuon_id,Values=$NUON_INSTALL_ID)

echo $SGS | jq -r '.SecurityGroups[].GroupId' | while read -r sg_id ; do
  echo "deleting security group $sg_id"
  aws ec2 delete-security-group --group-id=$sg_id
done

echo $SGS | jq -r '.SecurityGroups[].GroupId' | while read -r sg_id ; do
  echo "deleting security group $sg_id"
  aws ec2 delete-security-group --group-id=$sg_id
done

echo "looking for vpc..."
VPCS=$(aws ec2 \
  describe-vpcs \
  --filters Name=tag:nuon_id,Values=$NUON_INSTALL_ID)

echo $VPCS | jq -r '.Vpcs[].VpcId' | while read -r vpc_id ; do
  echo "deleting vpc $vpc_id"
  aws ec2 delete-vpc --vpc-id=$vpc_id
done
