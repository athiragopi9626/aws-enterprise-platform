# Architecture decision record — first deployment

**Use case:** standardize AWS networking for multiple future product squads. Reusable `modules/networking` builds two-AZ public/private subnets, deterministic subnet addressing, routing, and optional per-AZ NAT. The single deployment root is `environments/primary`.

**Decisions:**
1. One environment (`primary`) and one S3 state key. No Terraform workspaces, no second environment.
2. Reuse existing S3 bucket and GitHub OIDC role. Neither is provisioned here.
3. Use native S3 `.tflock` state locking, not deprecated DynamoDB locks.
4. CI on PR is credential-free. A true AWS plan is not safe to run against untrusted PR Terraform using a powerful deployment role. Approved push-to-main job does plan + apply.
5. Default NAT disabled: private subnets cannot reach the public internet. Enabling NAT provisions TWO NAT gateways and TWO EIPs, with hourly and data-processing charges. This is deliberate to avoid silently creating expensive resources.
6. Public subnet does not mean resources automatically receive public IPs. Public IP auto-assignment is disabled.
7. This milestone is a deployable **networking foundation**, not an ECS/RDS production platform. ECS/Fargate, HTTPS ALB, PostgreSQL, secrets, logs, restore testing, and deployment rollback require separate implementations and security review.

**Trade-offs:** A single VPC is simpler but not multi-account. NAT-off is cheaper but prevents private workloads pulling images or contacting public endpoints unless suitable VPC endpoints are later added. No production SLA or disaster recovery claim is made.
