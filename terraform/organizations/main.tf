# AWS Organizations Multi-Account Structure
# Creates organizational units and manages the account hierarchy

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-org-management"
    key            = "organizations/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
    kms_key_id     = "alias/terraform-state"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = "Enterprise-Account-Management"
      Environment = "organization"
    }
  }
}

# AWS Organization
resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ram.amazonaws.com",
    "ssm.amazonaws.com",
    "sso.amazonaws.com",
    "tagpolicies.tag.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "macie.amazonaws.com",
    "detective.amazonaws.com",
    "access-analyzer.amazonaws.com",
    "backup.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
    "BACKUP_POLICY",
    "AISERVICES_OPT_OUT_POLICY"
  ]

  feature_set = "ALL"
}

# Root OU (automatically created with organization)
data "aws_organizations_organization" "root" {
  depends_on = [aws_organizations_organization.main]
}

# Security OU
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Security and audit accounts"
    Purpose     = "Centralized security monitoring and audit logging"
  }
}

# Infrastructure OU
resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Shared infrastructure services"
    Purpose     = "Network, DNS, and shared services"
  }
}

# Production OU
resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Production workload accounts"
    Purpose     = "Production applications and data"
    CriticalData = "true"
  }
}

# Staging OU
resource "aws_organizations_organizational_unit" "staging" {
  name      = "Staging"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Staging environment accounts"
    Purpose     = "Pre-production testing"
  }
}

# Development OU
resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Development environment accounts"
    Purpose     = "Application development and experimentation"
  }
}

# Sandbox OU
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Sandbox accounts for learning and testing"
    Purpose     = "Individual developer experimentation"
  }
}

# Suspended OU (for decommissioned accounts)
resource "aws_organizations_organizational_unit" "suspended" {
  name      = "Suspended"
  parent_id = data.aws_organizations_organization.root.roots[0].id

  tags = {
    Description = "Suspended or decommissioned accounts"
    Purpose     = "Accounts pending closure"
  }
}

# Create core security accounts
resource "aws_organizations_account" "audit" {
  name      = var.audit_account_name
  email     = var.audit_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Name        = "Audit Account"
    Purpose     = "Centralized audit logging"
    Environment = "security"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "log_archive" {
  name      = var.log_archive_account_name
  email     = var.log_archive_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Name        = "Log Archive"
    Purpose     = "Long-term log retention"
    Environment = "security"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "security_tooling" {
  name      = var.security_tooling_account_name
  email     = var.security_tooling_account_email
  parent_id = aws_organizations_organizational_unit.security.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Name        = "Security Tooling"
    Purpose     = "Security Hub, GuardDuty aggregation"
    Environment = "security"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Create shared infrastructure account
resource "aws_organizations_account" "network" {
  name      = var.network_account_name
  email     = var.network_account_email
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  role_name = "OrganizationAccountAccessRole"

  tags = {
    Name        = "Network Account"
    Purpose     = "Transit Gateway, VPN, Direct Connect"
    Environment = "infrastructure"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Enable all features
resource "aws_organizations_policy" "example" {
  name = "example"

  content = <<CONTENT
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "*",
    "Resource": "*"
  }
}
CONTENT
}

# Delegated administrator for Security Hub
resource "aws_organizations_delegated_administrator" "securityhub" {
  account_id        = aws_organizations_account.security_tooling.id
  service_principal = "securityhub.amazonaws.com"
}

# Delegated administrator for GuardDuty
resource "aws_organizations_delegated_administrator" "guardduty" {
  account_id        = aws_organizations_account.security_tooling.id
  service_principal = "guardduty.amazonaws.com"
}

# Delegated administrator for Macie
resource "aws_organizations_delegated_administrator" "macie" {
  account_id        = aws_organizations_account.security_tooling.id
  service_principal = "macie.amazonaws.com"
}

# Delegated administrator for Config
resource "aws_organizations_delegated_administrator" "config" {
  account_id        = aws_organizations_account.audit.id
  service_principal = "config.amazonaws.com"
}

# Delegated administrator for CloudTrail
resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = aws_organizations_account.audit.id
  service_principal = "cloudtrail.amazonaws.com"
}
