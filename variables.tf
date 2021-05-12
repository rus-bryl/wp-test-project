#--------------VPC vars-----------------------------
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24",
  ]
}

#---------------WordPress vars---------------------------

variable "stack" {
  description = "this is name for tags"
  default     = "terraform"
}

variable "username" {
  description = "DB username"
  default     = "brm" # For testing
}

variable "password" {
  description = "DB password"
  default     = "pass" # For testing
}

variable "dbname" {
  description = "db name"
  default     = "DB" # For testing
}

variable "ssh_key" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Default pub key"
}

variable "ssh_priv_key" {
  default     = "~/.ssh/id_rsa"
  description = "Default key"
}
