variable "access_key" {
        description = "Access key to AWS console"
        default = "XXXXXXXXXXXXX"
}
variable "secret_key" {
        description = "Secret key to AWS console"
        default = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
}

#variable "aws_session_token" {
#        description = "Secret key to AWS console"
}

variable "vpc_id" {
         description = "vpc id "
         default = "vpc-XXXXXXXXXXXXXXXX"
}

variable "instance_name" {
        description = "Name of the instance to be created"
        default = "tf-testing"
}

variable "instance_type" {
        default = "t3.micro"
}

variable "subnet_id" {
        description = "The VPC subnet the instance(s) will be created in"
        default = "subnet-XXXXXXXXXXXXXXXXXX"
}

variable "ami_id" {
        description = "The AMI to use"
        default = "ami-XXXXXXXXXXXXXXXXXXXX"
}

variable "number_of_instances" {
        description = "number of instances to be created"
        default = 1
}


variable "ami_key_pair_name" {
        default = "testing"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"  # username which will be used while doing remote-execution with the launched instance.
}

variable "ssh_port" {
  default = 22
}