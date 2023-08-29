resource "aws_security_group" "ec2_sg" {
  name = "ec2_sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.ssh_port
    to_port   = var.ssh_port
    protocol  = "tcp"

    # To keep this example simple, we allow incoming SSH requests from any IP. In real-world usage, you should only
    # allow SSH requests from trusted servers, such as a bastion host or VPN server.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  userdata = templatefile("user_data.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}

resource "tls_private_key" "oskey" {
  algorithm = "RSA"
}

resource "local_file" "myterrakey" {
  content  = tls_private_key.oskey.private_key_pem
  filename = "myterrakey.pem"
}

resource "aws_key_pair" "key121" {
  key_name   = "myterrajana"
  public_key = tls_private_key.oskey.public_key_openssh
}

resource "aws_instance" "ec2_instance" {

    ami = data.aws_ami.ubuntu.id
    subnet_id = "${var.subnet_id}"
    tags = {
      pusatbiaya = "heelo-heelo"
      Name = "aws-ec2-001"
    }
    instance_type = "${var.instance_type}"
    iam_instance_profile = aws_iam_instance_profile.this.name
    user_data = local.userdata
    associate_public_ip_address = true
    key_name = aws_key_pair.key121.key_name
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    root_block_device {
      volume_size           = 20
      volume_type           = gp3
      encrypted             = true
      delete_on_termination = true
    }
  
    connection {
      type = "ssh"
      user = "ubuntu"    #var.INSTANCE_USERNAME
      private_key = tls_private_key.oskey.private_key_pem
      host        = aws_instance.ec2_instance.public_ip
    }

   provisioner "file" {
     source = "./script.sh"
     destination = "/tmp/script.sh"

     connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = tls_private_key.oskey.private_key_pem
      host     = aws_instance.ec2_instance.public_ip
      }
  } 

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/script.sh",
        "sudo /tmp/script.sh"
      ]
      on_failure = continue
    }
}


resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
     alarm_name                = "cpu-utilization-Alarm-${var.instance_name}"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "120" #seconds
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 cpu utilization"
     alarm_actions             = ["arn:aws:sns:ap-southeast-3:895242617166:Default_Cloudwatch_Alarms_Topics"]
     actions_enabled           = "true"
     insufficient_data_actions = []
dimensions = {
       InstanceId = aws_instance.ec2_instance.id
     }
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk" {
  alarm_name                = "EC2-DiskUsedPercent-Alarm-${var.instance_name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "disk_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 disk utilization"
  actions_enabled           = "true"
# dibawah ini musti diganti 
  alarm_actions             = ["arn:aws:sns:ap-southeast-3:895242617166:Default_Cloudwatch_Alarms_Topics"]
  insufficient_data_actions = []
  treat_missing_data = "notBreaching"

   dimensions = {
    InstanceId = aws_instance.ec2_instance.id
     path = "/"
     device = "nvme0n1p1"
     fstype = "ext4"
  }
  tags = {
            testing = "nicholas"

        }
  
}

resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  alarm_name                = "MemoryUtilization-Alarm-${var.instance_name}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "mem_used_percent"
  namespace                 = "CWAgent"
  period                    = "300"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 memory utilization"
  actions_enabled           = "true"
  alarm_actions             = ["arn:aws:sns:ap-southeast-3:XXXXXXXXXXXXXXXXXXXX:Default_Cloudwatch_Alarms_Topics"]
  insufficient_data_actions = []

   dimensions = {
    InstanceId = aws_instance.ec2_instance.id
    # ImageId = data.aws_ami.ubuntu.id
    # InstanceType = "${var.instance_type}"
  }
}


output "server_private_ip" {
  value = aws_instance.ec2_instance.private_ip
}