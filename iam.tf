## AWS Provider Block Intergrations ###
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.74.0"      
#     }
#   }
# }

## AWS Provider Block Intergrations ###
provider "aws" {
  # version = "~> 3.74.0"
  # version = "~> 4.39.0"
  # profile = "ps"
  # region = var.region
  alias = "default"
  default_tags {
    tags = {
      Owner       = "SecOps"
      Environment = "default"
    }
  }

}

# Partial configuration. The other settings (e.g., bucket, region) will be
# passed in from a file via -backend-config arguments to 'terraform init'
terraform {
  backend "s3" {
    # key = "global/secops/prisma_cloud/terraform.tfstate"
  }
}


# variable "accounts" {
#   description = "The name of the environment )"
#   type        = string

#   validation {
#     condition     = contains(["438171280653", "452418757197", "804656202561", "819417623337", "089902810488", "102553174541", "543800268692"], var.accounts)
#     error_message = "account hasn't been setup and not allowed:"
#   }
# }





## Create Role for prisma cloud Intergrations ###

resource "aws_iam_role" "PrismaCloud_role" {
  count = var.prismacloud
  name  = "${var.prismacloud}_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "AWS" : "188619942792"
          },
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : "EC0AD472-4E37-43F3-8195-FB6C2A7FB0A6"
            }
          }
        }
      ]
    }
  )
  provider = aws.default
    lifecycle {
    prevent_destroy = true
  }

}

  # provisioner "local-exec" {
  #   inline = ["echo \"Hello, World from $(uname -smp)\""]
  # }


data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
resource "aws_iam_role_policy_attachment" "SecurityAudit-policy-attach" {
  count      = var.prismacloud
  role       = aws_iam_role.PrismaCloud_role[count.index].name
  policy_arn = data.aws_iam_policy.SecurityAudit.arn
}


data "aws_iam_policy" "AWSSecurityHubReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AWSSecurityHubReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "AWSSecurityHubReadOnlyAccess-policy-attach" {
  count      = var.prismacloud
  role       = aws_iam_role.PrismaCloud_role[count.index].name
  policy_arn = data.aws_iam_policy.AWSSecurityHubReadOnlyAccess.arn
    lifecycle {
    prevent_destroy = true
  }  
}

data "aws_iam_policy" "AWSSecurityHubFullAccess" {
  arn = "arn:aws:iam::aws:policy/AWSSecurityHubFullAccess"
}
resource "aws_iam_role_policy_attachment" "AWSSecurityHubFullAccess-policy-attach" {
  count      = var.prismacloud
  role       = aws_iam_role.PrismaCloud_role[count.index].name
  policy_arn = data.aws_iam_policy.AWSSecurityHubFullAccess.arn
}


data "aws_iam_policy" "AWSSecurityHubServiceRolePolicy" {
  arn = "arn:aws:iam::aws:policy/aws-service-role/AWSSecurityHubServiceRolePolicy"
}
resource "aws_iam_role_policy_attachment" "AWSSecurityHubServiceRolePolicy-policy-attach" {
  count      = var.prismacloud
  role       = aws_iam_role.PrismaCloud_role[count.index].name
  policy_arn = data.aws_iam_policy.AWSSecurityHubServiceRolePolicy.arn
}


resource "aws_config_config_rule" "aws_config_config_rule" {
  count = var.awsConfig
  name  = "${var.awsConfig}_rule"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_VERSIONING_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.aws_configuration]
}

resource "aws_config_configuration_recorder" "aws_configuration" {
  count    = var.awsConfig
  name     = "awsConfig"
  role_arn = aws_iam_role.awsConfig_role[count.index].arn
}

resource "aws_iam_role" "awsConfig_role" {
  count              = var.awsConfig
  name               = "${var.awsConfig}_Role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "aws_iam_role_policy" {
  count = var.awsConfig
  name  = "${var.awsConfig}_Policy"
  role  = aws_iam_role.awsConfig_role[count.index].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "config:Put*",
          "Effect": "Allow",
          "Resource": "*"

      }
  ]
}
POLICY
}


resource "aws_s3_bucket" "test_s3bucket" {
  count  = var.test_s3bucket
  bucket = "random-testbucket0001"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count  = var.test_s3bucket
  bucket = aws_s3_bucket.test_s3bucket[count.index].id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default-encryption" {
  count  = var.test_s3bucket
  bucket = aws_s3_bucket.test_s3bucket[count.index].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}