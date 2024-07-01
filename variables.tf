variable "region" {
    description = "The aws region to be launched in"
    type = string
    default = "eu-west-1"
}

variable "env" {
  description = "Environment [string]"
}

variable "product" {
  type        = string
  default     = "ayoba"
  description = "Top Level Resources Identification [string]"
}

variable "stack" {
  description = "Stack Name for the set of resources [string]"
}

# EC2 Resource Variables

variable "ec2_instance_count_medium_app" {
  description = "The amount of runners for the xmpp set"
  type = number
}

variable "ec2_instance_type" {
  description = "The instance type for the datapro_collector"
  type = string
  default = "t3.medium"
}

variable "ec2_volume_size" {
  description = "Volume size of runner"
  type = string
  
}
variable "ec2_ami" {
  description = "instances ami to be used"
  type = string
  
}
variable "availability_zones" {
  type = list
  description = "Availability zones in a region"
}