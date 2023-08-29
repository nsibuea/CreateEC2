provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
#    token = "${var.aws_session_token}"
    region = "ap-southeast-3"
    default_tags {
        tags = {
            Environment = "Test"
            Owner       = "XXXXXXXXXXXXX"
            Project     = "Test"
        }
    }
}
