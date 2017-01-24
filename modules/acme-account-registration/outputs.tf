# ------------------------------------------
# Outputs required for use in other modules
# ------------------------------------------

output "registration_url" {
  value = "${acme_registration.reg.registration_url}"
}

output "registration_new_authz_url" {
  value = "${acme_registration.reg.registration_new_authz_url}"
}

output "registration_email" {
  value = "${var.acme_registration_email}"
}

output "registration_private_key_pem" {
  value = "${tls_private_key.acme_registration_private_key.private_key_pem}"
}

output "registration_public_key_pem" {
  value = "${tls_private_key.acme_registration_private_key.public_key_pem}"
}



