# ----------------------------------------------------------------
# Variables required for ACME provider demo
# ----------------------------------------------------------------

# Domain against which certificate will be created
# i.e. letsencrypt-terraform.example.com
variable "demo_domain_name"              { default = "example.com"}
variable "demo_domain_subdomain"         { default = "letsencrypt-terraform"}

# Leave blank here, supply securely at runtime 
variable "demo_acme_challenge_aws_access_key_id"     { }
variable "demo_acme_challenge_aws_secret_access_key" { }
variable "demo_acme_challenge_aws_region"            { }