variable "aws_region" {
  description = "AWS region for the management account"
  type        = string
  default     = "us-east-1"
}

variable "approved_regions" {
  description = "List of approved AWS regions for workloads"
  type        = list(string)
  default     = ["us-east-1", "us-west-2", "eu-west-1"]
}

# Security Accounts
variable "audit_account_name" {
  description = "Name for the audit account"
  type        = string
  default     = "Audit"
}

variable "audit_account_email" {
  description = "Email for the audit account"
  type        = string
}

variable "log_archive_account_name" {
  description = "Name for the log archive account"
  type        = string
  default     = "LogArchive"
}

variable "log_archive_account_email" {
  description = "Email for the log archive account"
  type        = string
}

variable "security_tooling_account_name" {
  description = "Name for the security tooling account"
  type        = string
  default     = "SecurityTooling"
}

variable "security_tooling_account_email" {
  description = "Email for the security tooling account"
  type        = string
}

# Infrastructure Accounts
variable "network_account_name" {
  description = "Name for the shared network account"
  type        = string
  default     = "SharedNetwork"
}

variable "network_account_email" {
  description = "Email for the network account"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
