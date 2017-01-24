# ----------------------------------------------------------------
# Inputs required to request a new cert from ACME Provider
# LetsEncrypt
# ----------------------------------------------------------------
variable "acme_server_url"                      {}
variable "acme_account_registration_url"        {}

variable "acme_account_key_pem"                 {}
variable "acme_certificate_common_name"         {}

variable "acme_challenge_aws_access_key_id"     {}
variable "acme_challenge_aws_secret_access_key" {}
variable "acme_challenge_aws_region"            {}


