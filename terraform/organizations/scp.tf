# Service Control Policies (SCPs)
# Preventive controls applied at OU and account level

# Deny root account usage
resource "aws_organizations_policy" "deny_root_account" {
  name        = "DenyRootAccountUsage"
  description = "Deny all actions by the root user"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyRootAccount"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# Deny leaving organization
resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "DenyLeaveOrganization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyLeaveOrganization"
        Effect   = "Deny"
        Action   = "organizations:LeaveOrganization"
        Resource = "*"
      }
    ]
  })
}

# Require MFA for sensitive operations
resource "aws_organizations_policy" "require_mfa" {
  name        = "RequireMFAForSensitiveOperations"
  description = "Require MFA for destructive operations"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RequireMFAForDelete"
        Effect = "Deny"
        Action = [
          "ec2:TerminateInstances",
          "rds:DeleteDBInstance",
          "s3:DeleteBucket",
          "dynamodb:DeleteTable",
          "elasticache:DeleteCacheCluster"
        ]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# Deny region restrictions (allow only approved regions)
resource "aws_organizations_policy" "region_restriction" {
  name        = "RegionRestriction"
  description = "Restrict operations to approved AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnapprovedRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cur:*",
          "directconnect:*",
          "ec2:DescribeRegions",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeVpnGateways",
          "fms:*",
          "globalaccelerator:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "kms:*",
          "mobileanalytics:*",
          "networkmanager:*",
          "organizations:*",
          "pricing:*",
          "route53:*",
          "route53domains:*",
          "s3:GetAccountPublic*",
          "s3:ListAllMyBuckets",
          "s3:PutAccountPublic*",
          "shield:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf-regional:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.approved_regions
          }
        }
      }
    ]
  })
}

# Deny unencrypted S3 uploads
resource "aws_organizations_policy" "require_s3_encryption" {
  name        = "RequireS3Encryption"
  description = "Deny S3 uploads without encryption"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedS3Uploads"
        Effect = "Deny"
        Action = "s3:PutObject"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = ["AES256", "aws:kms"]
          }
        }
      }
    ]
  })
}

# Deny unencrypted RDS creation
resource "aws_organizations_policy" "require_rds_encryption" {
  name        = "RequireRDSEncryption"
  description = "Require encryption for RDS instances"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedRDS"
        Effect = "Deny"
        Action = [
          "rds:CreateDBInstance",
          "rds:CreateDBCluster"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "rds:StorageEncrypted" = "false"
          }
        }
      }
    ]
  })
}

# Deny unencrypted EBS volumes
resource "aws_organizations_policy" "require_ebs_encryption" {
  name        = "RequireEBSEncryption"
  description = "Require encryption for EBS volumes"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyUnencryptedEBS"
        Effect = "Deny"
        Action = [
          "ec2:CreateVolume",
          "ec2:RunInstances"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "ec2:Encrypted" = "false"
          }
        }
      }
    ]
  })
}

# Deny CloudTrail disablement
resource "aws_organizations_policy" "protect_cloudtrail" {
  name        = "ProtectCloudTrail"
  description = "Prevent CloudTrail from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailDisablement"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      }
    ]
  })
}

# Deny GuardDuty disablement
resource "aws_organizations_policy" "protect_guardduty" {
  name        = "ProtectGuardDuty"
  description = "Prevent GuardDuty from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyGuardDutyDisablement"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DeleteMembers",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:StopMonitoringMembers",
          "guardduty:UpdateDetector"
        ]
        Resource = "*"
      }
    ]
  })
}

# Deny Config disablement
resource "aws_organizations_policy" "protect_config" {
  name        = "ProtectConfig"
  description = "Prevent AWS Config from being disabled"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyConfigDisablement"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}

# Sandbox OU - Restrictive policy
resource "aws_organizations_policy" "sandbox_restrictions" {
  name        = "SandboxRestrictions"
  description = "Restrictions for sandbox accounts"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyExpensiveInstances"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances"
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringNotLike = {
            "ec2:InstanceType" = [
              "t2.*",
              "t3.*",
              "t3a.*"
            ]
          }
        }
      },
      {
        Sid    = "DenyExpensiveRDS"
        Effect = "Deny"
        Action = [
          "rds:CreateDBInstance"
        ]
        Resource = "*"
        Condition = {
          StringNotLike = {
            "rds:DatabaseClass" = [
              "db.t2.*",
              "db.t3.*"
            ]
          }
        }
      }
    ]
  })
}

# Attach SCPs to OUs
resource "aws_organizations_policy_attachment" "deny_root_all" {
  policy_id = aws_organizations_policy.deny_root_account.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "deny_leave_all" {
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "region_restriction_all" {
  policy_id = aws_organizations_policy.region_restriction.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "require_mfa_prod" {
  policy_id = aws_organizations_policy.require_mfa.id
  target_id = aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_policy_attachment" "s3_encryption_all" {
  policy_id = aws_organizations_policy.require_s3_encryption.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "rds_encryption_all" {
  policy_id = aws_organizations_policy.require_rds_encryption.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "ebs_encryption_all" {
  policy_id = aws_organizations_policy.require_ebs_encryption.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "protect_cloudtrail_all" {
  policy_id = aws_organizations_policy.protect_cloudtrail.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "protect_guardduty_all" {
  policy_id = aws_organizations_policy.protect_guardduty.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "protect_config_all" {
  policy_id = aws_organizations_policy.protect_config.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "sandbox_restrictions" {
  policy_id = aws_organizations_policy.sandbox_restrictions.id
  target_id = aws_organizations_organizational_unit.sandbox.id
}
