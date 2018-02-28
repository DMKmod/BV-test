output "elb_dns_name" {
  value = "${aws_elb.web-lb.dns_name}"
}
