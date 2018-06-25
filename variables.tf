variable "name" {}

variable "tags" {
  type        = "map"
  default     = {}
  description = "A map of tags to add to all resources"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {}

variable "instance_type" {}
variable "instance_count" {}

variable "az_list" {
  type = "list"
}

variable "public_subnet_ids" {
  type = "list"
}

variable "private_subnet_ids" {
  type = "list"
}

variable "subnets_count" {
  description = "The number of subnets in public_subnet_ids. Required because of hashicorp/terraform#1497"
}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "aws_key_name" {}
variable "aws_key_location" {}

variable "ssh_user" {
  default = "centos"
}

variable "ssh_bastion_host" {
  default = ""
}

variable "ssh_bastion_user" {
  default = ""
}

variable "awsnycast_deb_url" {
  default = "https://github.com/bobtfish/AWSnycast/releases/download/v0.1.5/awsnycast_0.1.5-425_amd64.deb"
}

variable "route_table_identifier" {
  description = "Indentifier used by AWSnycast route table regexp"
  default     = "rt-private"
}
