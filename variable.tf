

variable "prismacloud" {
  description = "prismacloud"
  default     = 0
}

# variable "region_lch" {
#   type    = string
#   default = ""
# }

# # AWS account region for prod account
# variable "region_prod" {
#   type    = string
#   default = ""
# }

variable "awsConfig" {
  description = "awsConfig"
  default     = 0
}
variable "test_s3bucket" {
  description = "test_s3bucket"
  default     = 0
}

variable "new_relic_key" { type = string }

