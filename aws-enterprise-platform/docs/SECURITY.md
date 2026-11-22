# Security and approval model

- PR CI intentionally has **no AWS credentials**, no `id-token: write`, and does not read remote state. It performs `fmt`, `init -backend=false`, and `validate`. It is NOT a live plan. `primary-plan` is a GitHub environment label only.
- The push-to-main deploy job references `primary-deploy` and MUST be protected with required reviewers and branch restrictions (`main` only). GitHub environment approval occurs BEFORE checkout, OIDC assumption, plan and apply. The saved plan is created and applied in the same approved job.
- The existing OIDC role must restrict `aud=sts.amazonaws.com` and `sub` to the exact repository + `primary-deploy` environment, using the actual immutable subject format for a new 2026 repository. Do not use `repo:*` or broad `StringLike` wildcards. GitHub docs: https://docs.github.com/en/actions/reference/security/oidc
- GitHub `main` branch ruleset should require CI success, PR review and prevent direct pushes. Environment approval does not protect merges.
- `primary-deploy` environment variables: `AWS_ROLE_ARN`, `AWS_REGION`, `EXPECTED_AWS_ACCOUNT_ID`.
- The existing role must be audited for least privilege. This repository does not create or modify IAM trust policies. Review the account's existing role policy, state bucket policy, versioning, encryption, and Block Public Access before first deploy.
- The S3 state IAM policy needs ListBucket scoped to the key prefix; GetObject and PutObject on the state key; GetObject, PutObject, DeleteObject on the `.tflock` object; plus KMS access if the bucket uses a customer-managed key. NEVER grant DeleteObject on the state object solely for lockfile support.
- Do not put secrets in `.tfvars`, `backend.config`, or workflow files. Terraform state is sensitive even if no secrets are currently declared.
- `backend.config` is deliberately committed with placeholders and non-secret settings; replace it locally before first push. No credentials should be included.
- Action versions are major tags for readability; for stricter supply-chain security replace all `uses:` tags with audited full commit SHAs, and keep them updated through Dependabot.
- AWS default security group is not attached to any workload. Network resources alone are not an application security boundary; add explicit least-privilege security groups when deploying services.
