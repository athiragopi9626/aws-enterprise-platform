
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/vpc-flow-logs/${var.name}"
  retention_in_days = var.retention_in_days

  tags = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "delivery" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-flow-logs-delivery"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.delivery.json
}

resource "aws_flow_log" "this" {
  vpc_id                   = var.vpc_id
  traffic_type             = "ALL"
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.this.arn
  iam_role_arn             = aws_iam_role.this.arn
  max_aggregation_interval = 600

  tags = merge(var.tags, {
    Name = "${var.name}-flow-logs"
  })

  depends_on = [
    aws_iam_role_policy.this
  ]
}
