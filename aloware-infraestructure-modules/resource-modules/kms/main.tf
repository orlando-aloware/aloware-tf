resource "aws_kms_key" "this" {
  description              = var.description
  deletion_window_in_days  = var.deletion_window_in_days
  enable_key_rotation      = var.enable_key_rotation
  multi_region             = var.multi_region

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_kms_alias" "this" {
  count = var.alias != null ? 1 : 0
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}
