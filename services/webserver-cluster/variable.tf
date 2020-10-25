variable "s3_backend" {
  description = "The path to state file backend in S3"
  type        = string  
}

variable "ami" {
  description = "The AMI to run in the cluster"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "ssh_key" {
  description = "SSh key for instances"
  type        = string

}

variable "server_port" {
  description = "Port on which App listens"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}
variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for database's remote state key"
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in s3"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g t2.micro)"
  type        = string
}
variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
  type        = number
}
variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
  type        = number
}

locals {
  http_port = 80
  ssh_port  = 22
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

variable "custom_tags" {
  description = "Custom tags to set on the ASG instances"
  type        = map(string)
  default     = {} 
}

variable "enable_autoscaling" {
  description = "if set to true, enable auto scaling"
  type        = bool
}

variable "enable_new_user_data" {
  description = "If set to true, use the new user data script"
  type 	      = bool
}
