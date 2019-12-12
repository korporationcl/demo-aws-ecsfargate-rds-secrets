# Instructions

# Dependencies

## Running Terraform

This assumes we have created a profile within the AWS CLI named as `testing`. If this has been created then you
can proceed to the next stages, follow https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html if you need assistance with the profile setup process.

1. Create VPC, subnets and all the network layer:

```
terraform init --upgrade  -var-file="./terraform.tfvars"

terraform apply -var-file="./terraform.tfvars" -target=module.vpc
```

2.  Apply the rest of the infrastructure, deploy all the things:

```
$ terraform apply -var-file="./terraform.tfvars"
```


# NOTES

1. The design of this repository is not ideal, it is a simple flat structure without separation of resources. While this may work for a simple proof of concept, we should ideally create subdirectories for each part of the stack or use TF Workspaces.

2. Terraform hopefully should be encapsulated in a wrapper to make it easier (arguments are a bit longer at the moment even with a simple setup)

3. Due to the structure of this repository, it is not possible to deploy to different environments easily, evaluate TF Workspaces for that, or Terraform Cloud. 

4. There is no jumphost/bastion host deployed, so there is no way to access the internal resources. 

5. There is no Route53 zone. Although I could use AWS's service discovery with Fargate, I don't have a nice way to create DNS records for the other resources. 

6. ALB does not have a SSL listener, for this we need to deploy a valid SSL certificate (I consider this out of my scope/pocket).

7. Secrets by default are not encrypted in the state file (Terraform Cloud address this issue, but I can implement an S3 backend with encryption enabled) SSE which is `free`. Having said that, secrets are stored in AWS Secrets and Fargate should have access to them (someone needs to deploy them in a secure way).

