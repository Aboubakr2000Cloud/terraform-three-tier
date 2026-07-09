bucket         = "my-abou-terraform-state-bucket"
key            = "ecs-weather-platform/dev/terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
