# ----------------------------------------------------------------
# Inputs required to request a new cert from ACME provider
# ----------------------------------------------------------------

# Create a certificate
resource "acme_certificate" "certificate" {

  server_url              = "${var.acme_server_url}"
  account_key_pem         = "${var.acme_account_key_pem}"
  registration_url        = "${var.acme_account_registration_url}"
  common_name             = "${var.acme_certificate_common_name}"

  dns_challenge {
    provider = "route53"

    # Without this explicit config, the ACME provider (which uses lego
    # under the covers) will look for environment variables to use. 
    # These environment variable names happen to overlap with the names
    # also required by the native Terraform AWS provider, however is not 
    # guaranteed. You may want to explicitly configure them here if you
    # would like to use different credentials to those used by the main
    # Terraform provider
    config {
        AWS_ACCESS_KEY_ID     = "${var.acme_challenge_aws_access_key_id}"
        AWS_SECRET_ACCESS_KEY = "${var.acme_challenge_aws_secret_access_key}"
        AWS_REGION            = "${var.acme_challenge_aws_region}"
    }    
  }
}