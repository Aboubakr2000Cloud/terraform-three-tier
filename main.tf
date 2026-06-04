# ── VPC ──────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  name_prefix          = local.name_prefix
}

# ── Security Groups ───────────────────────────────────────────────
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id      = module.vpc.vpc_id
  my_ip       = var.my_ip
  name_prefix = local.name_prefix
}

# ── ALB ───────────────────────────────────────────────────────────
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = module.security_groups.alb_sg_id
  name_prefix       = local.name_prefix
}

# ── ASG ───────────────────────────────────────────────────────────
module "asg" {
  source = "./modules/asg"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.security_groups.app_sg_id
  target_group_arn   = module.alb.target_group_arn
  ami_id             = data.aws_ami.ubuntu.id
  instance_type      = var.instance_type
  key_name           = var.key_name
  user_data          = base64encode(file("${path.module}/userdata.sh"))
  name_prefix        = local.name_prefix
  min_size           = var.asg_min_size
  max_size           = var.asg_max_size
  desired_capacity   = var.asg_desired_capacity
}

# ── RDS ───────────────────────────────────────────────────────────
module "rds" {
  source = "./modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
  name_prefix        = local.name_prefix
}
