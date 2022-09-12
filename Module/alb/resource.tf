# To prevent your load balancer from being deleted accidentally, you can enable deletion protection. By default, deletion protection is disabled 
# for your load balancer. If you enable deletion protection for your load balancer, you must disable it before you can delete the load balancer.

resource "aws_lb" "app_lb" {
  name               = "udit-app-lb"
  internal           = false            # internal means private ip k throuch communitcate krwana mtlb internet pr nahi ja skate
  load_balancer_type = "application"    #name  
  security_groups    = "${var.sg}"   # kis security group ko add krna h
  subnets            = [for i in var.subnets : i ] # lb creat ho raha h to uske target kis kis subnets m honge isliye unhe add kre
  enable_deletion_protection = true
  
#   availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"] # bhi de sakte h 
}

#------------------------------------------------------------------------------------------------------------------------------------

# creating listernes 

resource "aws_lb_listener" "alb_listner_1" {
  load_balancer_arn = aws_lb.app_lb.arn   # means ye listner kisse attach amazon resource name se attach hoga  
  port              = "80"
  protocol          = "HTTP"

#  for https security ssl certificate
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
# default action mtlb default path / ye h means ye listner sirf http 80 pr hi request sunega or defualt path = / pr path change ho sake h /login... /registration etc

  default_action {      
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1.arn
  }
}

resource "aws_lb_listener" "alb_listner_2" {
  load_balancer_arn = aws_lb.app_lb.arn   
  port              = "81"
  protocol          = "HTTP"
  default_action {                       
     type             = "forward"
    target_group_arn = aws_lb_target_group.tg_2.arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

# creating target group 
resource "aws_lb_target_group" "tg_1" {
  name     = "udit-target-group-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"
  target_type = "instance"

  health_check {
    interval = 5
    path = "/"
    protocol = "HTTP"
    timeout = 2
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
} 
resource "aws_lb_target_group" "tg_2" {
  name     = "udit-target-group-2"
  port     = 81
  protocol = "HTTP"
  vpc_id   = "${var.vpc-id}"
  target_type = "instance"

   health_check {
    interval = 5
    path = "/"
    protocol = "HTTP"
    timeout = 2
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
}


# attach the instance to tha target group
resource "aws_lb_target_group_attachment" "tg_attach_1" {
  target_group_arn = aws_lb_target_group.tg_1.arn
  target_id        = "${element(var.tg-ec-id,0)}" 
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attach_2" {
  target_group_arn = aws_lb_target_group.tg_2.arn
  target_id        = "${element(var.tg-ec-id,2)}" 
  port             = 81
}

