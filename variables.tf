variable "env" {}

variable "component" {}

variable "tags" {
  default = {}
}
variable "subnets" {}
variable "vpc_id" {}
variable "app_port" {}
variable "sg_subnets_cidr" {}
variable "kms_key_id" {}
variable "instance_type" {}
#variable "name" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "allow_ssh_cidr" {}
variable "lb_dns_name" {}
variable "listener_arn" {}
variable "lb_rule_priority" {}
variable "kms_arn" {}