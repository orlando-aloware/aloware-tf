resource "aws_route53_zone" "this" {
  count = var.create_zone ? 1 : 0

  name = var.zone_name

  dynamic "vpc" {
    for_each = var.private_zone ? [1] : []
    content {
      vpc_id = var.vpc_id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = var.zone_name
    }
  )
}

resource "aws_route53_record" "this" {
  for_each = var.records

  zone_id = var.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = lookup(alias.value, "evaluate_target_health", false)
    }
  }
}
