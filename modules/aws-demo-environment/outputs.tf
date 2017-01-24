output "demo_env_elb_dnsname" {
  value = "${aws_elb.web.dns_name}"
}

