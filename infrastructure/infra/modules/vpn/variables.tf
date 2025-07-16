variable "client_cidr_block" {
  description = "CIDR block assigned to VPN clients"
  type        = string
  default     = "10.11.0.0/22"
}

variable "subnet_ids" {
  description = "Subnet to associate VPN with"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block of your VPC"
  type        = string
}
