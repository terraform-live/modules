################### Define data sources here ###################

## Remote State for db ##

data "terraform_remote_state" "db" {
	backend = "s3"
	config = {
		bucket = var.db_remote_state_bucket
		key    = var.db_remote_state_key
		region = "us-east-2"
	}
}

data "aws_vpc" "default" {
     default = true
}

data "aws_subnet_ids" "default" {
     vpc_id = data.aws_vpc.default.id
}

## User Data ##
data "template_file" "user_data" {
	template = file("${path.module}/user-data.sh")

	vars = {
		server_port = var.server_port
		db_address  = data.terraform_remote_state.db.outputs.address
		db_port			= data.terraform_remote_state.db.outputs.port
	}
}
################### SSH Key ###################
resource "aws_key_pair" "deployer" {
  key_name   = var.ssh_key
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC74QjI9F/q2ORxNrPT1OszLSHdWE5uAIMBNzuudR3esovVH74/k7AfHTF8CHaLmZ/8ToRrHGlzHdnzR4tfAXm3LfZ2xrd1E+6SP7q/TEEFf+vYhYiTO5rUV7IGiON3ZBj4UOh3mQ5wQtwquVqszn7dNofMA37zSorUuutX18Lzt3FqKT51G37zWVaK9JPMqPCeeDqKngJvX1i8QAJT8VipF0rlSo71dHPVr8zIoE/LUf8ytuab1Lom4leMG86qK2pw+givXqiqjUcnTX4enhZGtK/ai/pJpwhcABpuC21TMCF5p0Z3PTkrZhno8MTi8+trIK2z+nD4gVdeciGBs4w5 Chysome@McNathan"
}
################### Instance security Group ###################

resource "aws_security_group" "instance" {
  name        = "${var.cluster_name}-instance"
}
resource "aws_security_group_rule" "instance_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = var.server_port
  to_port           = var.server_port
  protocol          = local.tcp_protocol
  cidr_blocks       = local.all_ips
  }

	resource "aws_security_group_rule" "instance_outbound" {
    type        = "egress"
    security_group_id = aws_security_group.instance.id
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "instance_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port         = local.ssh_port
  to_port           = local.ssh_port
  protocol          = local.tcp_protocol
  cidr_blocks       = ["68.134.166.135/32"]
  }

################### Configure Autoscaling Group ###################

resource "aws_launch_configuration" "example" {
	image_id 				= "ami-0c55b159cbfafe1f0"
	instance_type		= var.instance_type
	security_groups	= [aws_security_group.instance.id]
	user_data				= data.template_file.user_data.rendered
	key_name				= aws_key_pair.deployer.key_name

	lifecycle {
	   create_before_destroy = true
     }
}

resource "aws_autoscaling_group" "example" {
	launch_configuration = aws_launch_configuration.example.name	
	vpc_zone_identifier  = data.aws_subnet_ids.default.ids
      
	target_group_arns = [aws_lb_target_group.asg.arn]
	health_check_type = "ELB"

  min_size = var.min_size
	max_size = var.max_size

	tag {
	   key = "Name"
           value = var.cluster_name
           propagate_at_launch = true
	}
}

################### Configure Application Load Balancer ###################

resource "aws_lb" "example" {
	name = "${var.cluster_name}-example"
	load_balancer_type = "application"
	subnets		   = data.aws_subnet_ids.default.ids
	security_groups	   = [aws_security_group.alb.id]
}

resource "aws_security_group" "alb" {
  name        = "${var.cluster_name}-alb"
}
resource "aws_security_group_rule" "allow_http_inbound" {
    type              = "ingress"
    security_group_id = aws_security_group.alb.id
    from_port         = local.http_port
    to_port           = local.http_port
    protocol          = local.tcp_protocol
    cidr_blocks       = local.all_ips
  }
resource "aws_security_group_rule" "allow_http_outbound" {
    type        = "egress"
    security_group_id = aws_security_group.alb.id
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
}


resource "aws_lb_listener" "http" {
	load_balancer_arn = aws_lb.example.arn
	port		  = local.http_port
	protocol	= "HTTP"

	default_action {
	    type	= "fixed-response"

	    fixed_response {
				content_type = "text/plain"
				message_body = "404: Not found"
				status_code  = 404
            }
        }
}    

resource "aws_lb_listener_rule" "asg" {
	listener_arn = aws_lb_listener.http.arn
	priority     = 100

	condition {
	   path_pattern {
        values   = ["*"]
     }
	}

	action {
     type	      = "forward"
	   target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
	name = "${var.cluster_name}-example"
	port = var.server_port
	protocol = "HTTP"
	vpc_id	 = data.aws_vpc.default.id

	health_check {
		path	 =	"/"
		protocol = "HTTP"
		matcher  = "200"
		interval = 15
		timeout	 = 3
		healthy_threshold   = 2
		unhealthy_threshold = 2
	}
}

