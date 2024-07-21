resource "aws_iam_role" "github_actions_role" {
  name = "udacity-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::607531995438:oidc-provider/token.actions.githubusercontent.com"
        },
        Action: "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringLike": {
              "token.actions.githubusercontent.com:sub": "repo:circobit/deployment-roulette:*"
          },
          "ForAllValues:StringEquals": {
              "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com",
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    actions = [
      "eks:DescribeCluster"
    ]
    resources = [
      module.project_eks.cluster_arn
    ]
  }

  statement {
    actions = [
      "eks:AssumeRole"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    resources = [
      aws_iam_role.github_actions_role.arn
    ]
  }

  statement {
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "eks:ListNodegroups",
      "eks:DescribeNodegroup",
      "eks:ListFargateProfiles",
      "eks:DescribeFargateProfile"
    ]
    resources = [
      aws_iam_role.github_actions_role.arn
    ]
  }

  statement {
    actions = [
      "eks:AccessKubernetesApi"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "eks:Resource"
      values = [
        "namespaces/udacity",
        "deployments/canary-v1",
        "deployments/canary-v2",
        "namespaces/default"
      ]
    }
  }

  statement {
    actions = [
      "eks:ListPods"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "eks:Resource"
      values = [
        "namespaces/udacity"
      ]
    }
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "github_actions_policy"
  description = "IAM policy for GitHub Actions runner with limited EKS permissions"
  policy      = data.aws_iam_policy_document.github_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_github_actions_policy" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}