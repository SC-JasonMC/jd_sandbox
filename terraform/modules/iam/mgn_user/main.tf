resource "aws_iam_group" "rock_mgn" {
  name = "rock_mgn"
  path = "/users/"
}

resource "aws_iam_group_policy_attachment" "rock_mgn_policy_attach" {
  group      = aws_iam_group.rock_mgn.name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationAgentInstallationPolicy"
}

resource "aws_iam_user" "mgn_user" {
  name = "${var.resource_prefix}-user"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "mgn_user_access_key" {
  user = aws_iam_user.mgn_user.name
}

resource "aws_iam_user_group_membership" "mgn_user_group_membership" {
  user = aws_iam_user.mgn_user.name

  groups = [
    aws_iam_group.rock_mgn.name,
  ]
}

resource "aws_secretsmanager_secret" "mgn_user_creds" {
  name = "rock_mgn_user_credentials"
}

resource "aws_secretsmanager_secret_version" "mgn_user_creds_value" {
  secret_id     = aws_secretsmanager_secret.mgn_user_creds.id
  secret_string = jsonencode(
    {
        access_key_id     = aws_iam_access_key.mgn_user_access_key.id
        secret_access_key = aws_iam_access_key.mgn_user_access_key.secret
        }
    )
}