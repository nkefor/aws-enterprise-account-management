# Tag Policies
# Enforce consistent tagging across the organization

resource "aws_organizations_policy" "tag_policy" {
  name        = "RequiredTagsPolicy"
  description = "Enforce required tags on resources"
  type        = "TAG_POLICY"

  content = jsonencode({
    tags = {
      Environment = {
        tag_key = {
          "@@assign" = "Environment"
        }
        tag_value = {
          "@@assign" = [
            "production",
            "staging",
            "development",
            "sandbox"
          ]
        }
        enforced_for = {
          "@@assign" = [
            "ec2:instance",
            "ec2:volume",
            "rds:db",
            "s3:bucket",
            "lambda:function"
          ]
        }
      }
      CostCenter = {
        tag_key = {
          "@@assign" = "CostCenter"
        }
        enforced_for = {
          "@@assign" = [
            "ec2:instance",
            "ec2:volume",
            "rds:db",
            "s3:bucket"
          ]
        }
      }
      Owner = {
        tag_key = {
          "@@assign" = "Owner"
        }
        enforced_for = {
          "@@assign" = [
            "ec2:instance",
            "rds:db",
            "s3:bucket"
          ]
        }
      }
      Application = {
        tag_key = {
          "@@assign" = "Application"
        }
        enforced_for = {
          "@@assign" = [
            "ec2:instance",
            "rds:db",
            "lambda:function"
          ]
        }
      }
    }
  })
}

# Backup Policy
# Enforce backup requirements

resource "aws_organizations_policy" "backup_policy" {
  name        = "OrganizationBackupPolicy"
  description = "Enforce backup requirements across accounts"
  type        = "BACKUP_POLICY"

  content = jsonencode({
    plans = {
      ProductionBackupPlan = {
        regions = {
          "@@assign" = var.approved_regions
        }
        rules = {
          DailyBackup = {
            target_backup_vault_name = {
              "@@assign" = "Default"
            }
            schedule_expression = {
              "@@assign" = "cron(0 5 ? * * *)"
            }
            start_backup_window_minutes = {
              "@@assign" = 60
            }
            complete_backup_window_minutes = {
              "@@assign" = 120
            }
            lifecycle = {
              delete_after_days = {
                "@@assign" = 35
              }
              move_to_cold_storage_after_days = {
                "@@assign" = 7
              }
            }
            recovery_point_tags = {
              BackupType = {
                tag_value = {
                  "@@assign" = "Daily"
                }
              }
            }
          }
          WeeklyBackup = {
            target_backup_vault_name = {
              "@@assign" = "Default"
            }
            schedule_expression = {
              "@@assign" = "cron(0 5 ? * 1 *)"
            }
            start_backup_window_minutes = {
              "@@assign" = 60
            }
            complete_backup_window_minutes = {
              "@@assign" = 120
            }
            lifecycle = {
              delete_after_days = {
                "@@assign" = 90
              }
              move_to_cold_storage_after_days = {
                "@@assign" = 30
              }
            }
            recovery_point_tags = {
              BackupType = {
                tag_value = {
                  "@@assign" = "Weekly"
                }
              }
            }
          }
        }
        selections = {
          tags = {
            ProductionResources = {
              iam_role_arn = {
                "@@assign" = "arn:aws:iam::$account:role/service-role/AWSBackupDefaultServiceRole"
              }
              resources = {
                "@@assign" = ["arn:aws:*:*:*:*"]
              }
              conditions = {
                StringEquals = [
                  {
                    ConditionKey = "aws:ResourceTag/Environment"
                    ConditionValue = ["production"]
                  }
                ]
              }
            }
          }
        }
      }
    }
  })
}

# AI Services Opt-Out Policy
# Control usage of AI services for data privacy

resource "aws_organizations_policy" "ai_opt_out" {
  name        = "AIServicesOptOut"
  description = "Opt out of AI services using customer data for improvement"
  type        = "AISERVICES_OPT_OUT_POLICY"

  content = jsonencode({
    services = {
      "@@operators_allowed_for_child_policies" = ["@@none"]
      default = {
        "@@operators_allowed_for_child_policies" = ["@@none"]
        opt_out_policy = {
          "@@operators_allowed_for_child_policies" = ["@@none"]
          "@@assign"                               = "optOut"
        }
      }
    }
  })
}

# Attach policies to OUs
resource "aws_organizations_policy_attachment" "tag_policy_root" {
  policy_id = aws_organizations_policy.tag_policy.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}

resource "aws_organizations_policy_attachment" "backup_policy_prod" {
  policy_id = aws_organizations_policy.backup_policy.id
  target_id = aws_organizations_organizational_unit.production.id
}

resource "aws_organizations_policy_attachment" "ai_opt_out_all" {
  policy_id = aws_organizations_policy.ai_opt_out.id
  target_id = data.aws_organizations_organization.root.roots[0].id
}
