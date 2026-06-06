locals {
  name_prefix = "terraform-three-tier-${var.environment}"
  common_tags = {
    Project     = "terraform-three-tier"
    Environment = var.environment
    ManagedBy   = "terraform"
    Week        = "16"
    Owner       = "Abou"
  }
}


