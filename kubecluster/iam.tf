
resource "aws_iam_policy" "demo-s3-policy" {
  name        = "S3-Bucket-Access-Policy"
  description = "Provides permission to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:putObject",
          "s3:Create*",
          "s3:list*",
          "ssm:GetParameters",
          "ssm:GetParameter",
        ]
        Effect = "Allow"
        Resource = [
        "*"]
      },
    ]
  })
}


resource "aws_iam_role" "demo-role" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "demo-attach" {
  name       = "demo-attachment"
  roles      = [aws_iam_role.demo-role.name]
  policy_arn = aws_iam_policy.demo-s3-policy.arn
}

resource "aws_iam_instance_profile" "demo-profile" {
  name = "demo_profile"
  role = aws_iam_role.demo-role.name
}

