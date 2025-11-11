resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name            = each.value.name
  description     = lookup(each.value, "description", null)
  type            = lookup(each.value, "type", "String")
  value           = each.value.value
  tier            = lookup(each.value, "tier", "Standard")
  key_id          = lookup(each.value, "key_id", null)
  allowed_pattern = lookup(each.value, "allowed_pattern", null)
  data_type       = lookup(each.value, "data_type", null)

  tags = merge(
    var.tags,
    lookup(each.value, "tags", {}),
    {
      Name = each.value.name
    }
  )
}
