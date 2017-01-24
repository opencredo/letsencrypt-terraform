# ----------------------------------------------------------------
# Variables required for ACME provider registration
# ----------------------------------------------------------------

# Let's Encrypt Account Registration Config
# -- Production
# variable "demo_acme_server_url"          { default = "https://acme.api.letsencrypt.org/directory"}
# variable "demo_acme_registration_email"  { default = "your-email@your-company.com" }
# -- Staging
variable "demo_acme_server_url"          { default = "https://acme-staging.api.letsencrypt.org/directory"}
variable "demo_acme_registration_email"  { default = "your-email@example.com" }

