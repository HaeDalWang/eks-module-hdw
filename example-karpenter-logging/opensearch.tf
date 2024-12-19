# 로그 저장용 OpenSearch
module "opensearch_log" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "1.2.2"

  domain_name    = "haedal-log"
  engine_version = "OpenSearch_2.13"

  cluster_config = {
    dedicated_master_enabled = false
    instance_type            = "t3.medium.search"
    instance_count           = 1
    zone_awareness_enabled   = false
  }

  ebs_options = {
    volume_size = 20
  }

  advanced_security_options = {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options = {
      master_user_arn      = null
      master_user_name     = "admin"
      master_user_password = "Bsd0705!"
    }
  }

  access_policy_statements = [
    {
      effect = "Allow"

      principals = [{
        type        = "*"
        identifiers = ["*"]
      }]

      actions = ["es:*"]
    }
  ]

  auto_tune_options = {
    desired_state = "DISABLED"
  }

  log_publishing_options = []
}