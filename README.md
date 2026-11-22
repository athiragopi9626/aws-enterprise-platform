# AWS Enterprise Platform — secure Terraform foundation

Portfolio project: reusable AWS VPC networking for a hypothetical product engineering platform. **This repository's current deliverable is the deployable networking foundation, not the full ECS/RDS application.**

## What's included
- `modules/networking`: two-AZ VPC, public/private subnets, routing, optional NAT per AZ.
- `environments/primary`: sole Terraform root; existing S3 backend in `backend.config` with S3 native state locking.
- `.github/workflows/terraform-ci.yml`: PR validation (`primary-plan`), **no AWS credentials**.
- `.github/workflows/terraform-deploy.yml`: push to main, required environment approval (`primary-deploy`), OIDC, fresh plan and apply.
- Security and design notes under `docs/`.

## Before first use (mandatory)
1. Create a new GitHub repository, set branch protection on `main` requiring PR reviews and the `Terraform format and validate` status check. Do not bypass rules with direct pushes.
2. Create GitHub environments `primary-plan` (no approval) and `primary-deploy` (**required reviewers** and **main-only** deployment branch restriction). If only you can approve, do not enable prevent-self-review.
3. Set `primary-deploy` environment variables: `AWS_ROLE_ARN`, `AWS_REGION`, `EXPECTED_AWS_ACCOUNT_ID`. Confirm GitHub plan supports required reviewers.
4. Check the EXISTING IAM OIDC role trust policy for the new repo's actual subject claim (new GitHub repos in 2026 may use immutable owner/repo IDs). Require `aud=sts.amazonaws.com` and exact `sub` for `primary-deploy`. The GitHub environment name changes `sub` format. Avoid broad repository wildcards.
5. Verify role permissions for EC2 VPC/subnets/routes/IGW/tags, and optional NAT/EIP only if enabled. Check S3 state access and lockfile permissions; bucket versioning, encryption, Block Public Access, and KMS policy if applicable.
6. Edit `environments/primary/backend.config`: enter actual existing S3 bucket and its region. State key must be unique to this project. Never add credentials.
7. Adjust `aws_region` in `terraform.tfvars` (create from example), or keep the default `eu-west-1`. The S3 backend bucket can be in a different region.
8. Locally run `terraform fmt -recursive`, `terraform init -backend-config=backend.config`, `terraform validate`, `terraform plan` with your own authorized AWS identity before enabling automated apply. Commit the generated `.terraform.lock.hcl` to lock provider selections.
9. Open a PR; verify CI. Merge only after review; then approve the `primary-deploy` environment deployment. Confirm the AWS account ID guard succeeds.

## Local commands
```bash
cd environments/primary
cp terraform.tfvars.example terraform.tfvars
terraform fmt -recursive ../../
terraform init -backend-config=backend.config
terraform validate
terraform plan -out=tfplan
# Manual apply only after carefully reviewing the plan:
terraform show tfplan
terraform apply tfplan
```

## Cost and cleanup
Default deployment creates VPC/subnets/route tables/IGW; these resources generally have no hourly charge, but AWS charges may arise from associated services, public IPv4, data transfer, or future resources. **NAT disabled by default**. If you enable NAT, two NAT gateways and EIPs incur charges. Review AWS pricing in your region and set a budget before deploying. For cleanup, use the same backend and authorized identity: `terraform destroy` after reviewing its plan; retain S3 state bucket, which is externally managed.

## Security limitations
This is a portfolio lab, not independently audited production code. Terraform CLI and provider must be validated in your environment. No live AWS deployment has been performed by the authoring assistant. GitHub actions major version tags should be pinned to reviewed SHAs before production use. See `docs/SECURITY.md`.

## Official references
- HashiCorp S3 backend: https://developer.hashicorp.com/terraform/language/backend/s3
- AWS Terraform backend best practices: https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/backend.html
- GitHub AWS OIDC: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
- GitHub OIDC immutable subjects: https://docs.github.com/en/actions/reference/security/oidc
- AWS Terraform CI/CD workshop: https://catalog.workshops.aws/terraform-cicd-on-aws/en-US/1-introduction
