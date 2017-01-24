# ------------------------------------------
#  AWS ROUTE53 : Domain creation
# ------------------------------------------

# This assumes that you have already (out of band) setup AWS as your
# DNS provider, and created a hosted zone again the main domain, e.g
# against example.com. This datasource simply looks up the zone details 
# to use in the creation of the additional sub domain records.

data "aws_route53_zone" "main" {
  name         = "${var.dns_domain_name}"
  private_zone = false
}

resource "aws_route53_record" "letsencrypt-terraform" {
   zone_id = "${data.aws_route53_zone.main.zone_id}"
   name    = "${var.dns_domain_subdomain}.${data.aws_route53_zone.main.name}"
   type    = "CNAME"
   ttl     = "60"
   records = ["${var.dns_cname_value}"]
}
