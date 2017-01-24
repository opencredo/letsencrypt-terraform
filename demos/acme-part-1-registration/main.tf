# ------------------------------------------------------------
# Use terraform to perform an ACME account registration
# ------------------------------------------------------------
module "acme-reg" {
    source = "../../modules/acme-account-registration"
    acme_server_url          = "${var.demo_acme_server_url}" 
    acme_registration_email  = "${var.demo_acme_registration_email}"
}

# ------------------------------------------------------------
# Output any ACME registration variables which   
# A) will be required for use in part 2 of the process and/or
# B) might be helpful for storing for later use
# ------------------------------------------------------------
output "server_url" {
  value = "${var.demo_acme_server_url}"
}

output "registration_email" {
  value = "${module.acme-reg.registration_email}"
}

output "registration_url" {
  value = "${module.acme-reg.registration_url}"
}

output "registration_new_authz_url" {
  value = "${module.acme-reg.registration_new_authz_url}"
}

output "registration_public_key_pem" {
  value = "${module.acme-reg.registration_public_key_pem}"
}

#
# This registration private key is only being outputed here to 
# make it easier to demonstrate a decoupled terraform only 
# registration and cert request process. As this is however 
# a sensitive value, in reality you would not do this, but 
# rather you would do the process out of band and then simply
# make it available for part 2. Currently creating local files
# via terraform is also not supported, ref
# https://github.com/hashicorp/terraform/issues/9718
#
output "registration_private_key_pem" {
  value = "${module.acme-reg.registration_private_key_pem}"
}
