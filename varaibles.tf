
variable "vpc_id" {
  type = string
  default  = "vpc-0cf39978e72298797" 
}
variable "public_subnet_id" {
  type = string
  default= "subnet-0a4fb68f05edd8d93"
}
variable "security_group_id" {
  type = string
  default= "sg-057175982ddb339a6"  
}
variable "instance_type" {
  type = string
  default = "t2.medium"
}
variable "ami" {
  type = string
  default= "ami-0e001c9271cf7f3b9"
}
variable "key_pair_name" {
  description = "key name" 
  type = string
  default= "pfe-key"
}
variable "disk_size" {
  type = number
  default = 20  
}
