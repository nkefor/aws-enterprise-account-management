output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.main.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = aws_organizations_organization.main.arn
}

output "organization_root_id" {
  description = "The ID of the organization root"
  value       = data.aws_organizations_organization.root.roots[0].id
}

output "organization_master_account_id" {
  description = "The ID of the master/management account"
  value       = aws_organizations_organization.main.master_account_id
}

# OU IDs
output "security_ou_id" {
  description = "The ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  description = "The ID of the Infrastructure OU"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "production_ou_id" {
  description = "The ID of the Production OU"
  value       = aws_organizations_organizational_unit.production.id
}

output "staging_ou_id" {
  description = "The ID of the Staging OU"
  value       = aws_organizations_organizational_unit.staging.id
}

output "development_ou_id" {
  description = "The ID of the Development OU"
  value       = aws_organizations_organizational_unit.development.id
}

output "sandbox_ou_id" {
  description = "The ID of the Sandbox OU"
  value       = aws_organizations_organizational_unit.sandbox.id
}

output "suspended_ou_id" {
  description = "The ID of the Suspended OU"
  value       = aws_organizations_organizational_unit.suspended.id
}

# Account IDs
output "audit_account_id" {
  description = "The ID of the Audit account"
  value       = aws_organizations_account.audit.id
}

output "log_archive_account_id" {
  description = "The ID of the Log Archive account"
  value       = aws_organizations_account.log_archive.id
}

output "security_tooling_account_id" {
  description = "The ID of the Security Tooling account"
  value       = aws_organizations_account.security_tooling.id
}

output "network_account_id" {
  description = "The ID of the Network account"
  value       = aws_organizations_account.network.id
}

# SCP IDs
output "deny_root_account_policy_id" {
  description = "The ID of the Deny Root Account SCP"
  value       = aws_organizations_policy.deny_root_account.id
}

output "region_restriction_policy_id" {
  description = "The ID of the Region Restriction SCP"
  value       = aws_organizations_policy.region_restriction.id
}

# Configuration
output "organization_feature_set" {
  description = "The feature set enabled for the organization"
  value       = aws_organizations_organization.main.feature_set
}

output "enabled_policy_types" {
  description = "List of enabled policy types"
  value       = aws_organizations_organization.main.enabled_policy_types
}

# Delegated administrators
output "securityhub_delegated_admin" {
  description = "Security Hub delegated administrator account"
  value       = aws_organizations_account.security_tooling.id
}

output "guardduty_delegated_admin" {
  description = "GuardDuty delegated administrator account"
  value       = aws_organizations_account.security_tooling.id
}

output "config_delegated_admin" {
  description = "AWS Config delegated administrator account"
  value       = aws_organizations_account.audit.id
}
