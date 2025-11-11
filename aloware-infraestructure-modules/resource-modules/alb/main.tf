module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = var.name

  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets
  security_groups    = var.security_groups

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  access_logs = var.access_logs

  target_groups = var.target_groups
  http_tcp_listeners = var.http_tcp_listeners
  https_listeners = var.https_listeners

  tags = var.tags
}
