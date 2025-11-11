resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name               = var.role_name
  description        = var.role_description
  assume_role_policy = var.assume_role_policy

  max_session_duration = var.max_session_duration

  tags = merge(
    var.tags,
    {
      Name = var.role_name
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create_role ? var.role_policy_arns : {}

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_policy" "this" {
  count = var.create_policy ? 1 : 0

  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_document

  tags = merge(
    var.tags,
    {
      Name = var.policy_name
    }
  )
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0

  name = var.instance_profile_name
  role = aws_iam_role.this[0].name

  tags = var.tags
}
