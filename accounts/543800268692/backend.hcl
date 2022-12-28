# backend.hcl
bucket         = "lch-terraform-backend"
key = "global/terraform/prisma_cloud/terraform.tfstate"
region         = "us-west-2"
encrypt        = true