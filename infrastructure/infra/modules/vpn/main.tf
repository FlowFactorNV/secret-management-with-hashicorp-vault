# Root CA key and self-signed cert
resource "tls_private_key" "root" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "MyRootCA"
    organization = "MyOrg"
  }

  validity_period_hours = 87600  # 10 years
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

# Server key and CSR
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name  = "vpn.example.com"
    organization = "MyOrg"
  }
}

# Server cert signed by Root CA
resource "tls_locally_signed_cert" "server" {
  cert_request_pem = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem         = tls_self_signed_cert.root.cert_pem

  validity_period_hours = 8760  # 1 year
  allowed_uses = [
    "server_auth",
    "key_encipherment",
    "digital_signature",
  ]
}

# Import server cert to ACM
resource "aws_acm_certificate" "cert" {
  private_key       = tls_private_key.server.private_key_pem
  certificate_body  = tls_locally_signed_cert.server.cert_pem
  certificate_chain = tls_self_signed_cert.root.cert_pem
}

# Also import the root certificate (for client auth)
resource "aws_acm_certificate" "root_cert" {
  private_key       = tls_private_key.root.private_key_pem
  certificate_body  = tls_self_signed_cert.root.cert_pem
}


resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = "Simple Client VPN"
  server_certificate_arn = aws_acm_certificate.cert.arn
  client_cidr_block      = var.client_cidr_block

  connection_log_options {
    enabled = false
  }

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.root_cert.arn
  }

  transport_protocol = "udp"
  vpn_port           = 443
  split_tunnel       = true
  dns_servers        = ["8.8.8.8"]

  tags = {
    Name = "basic-client-vpn"
  }
}

locals {
  subnet_map = zipmap(
    [for i in range(length(var.subnet_ids)) : "subnet-${i}"],
    var.subnet_ids
  )
}

resource "aws_ec2_client_vpn_network_association" "associations" {
  for_each = local.subnet_map

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
