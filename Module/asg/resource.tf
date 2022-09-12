resource "aws_launch_configuration" "lc" {
  name = "udit-launch-config"
  image_id = "${var.img-id}"
  instance_type = "t3.micro"
  security_groups = "${var.sg}"
  key_name = "${var.key-name}"

#   ebs_block_device {     # to add additional ebs volume to the autoscalled ec2 instances
#     volume_size = 32
#     iops = 300
#     delete_on_termination = true
#     encrypted = true
#     volume_type = "standard"
#   }

}

resource "aws_autoscaling_group" "udit-asg" {
  name                      = "udt-asg"
  max_size                  = 7
  min_size                  = 1
  desired_capacity          = 4
  health_check_grace_period = 300   #The amount of time, in seconds, that Amazon EC2 Auto Scaling waits before checking the health status of an EC2 instance that has come into service
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc.name
  vpc_zone_identifier       = [for i in var.subnets : i]
  target_group_arns = [for i in var.targets : i]
}

# creating asg policy
resource "aws_autoscaling_policy" "udit-policy" {
  name                   = "udit-asg-policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300  #Amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start.
  autoscaling_group_name = aws_autoscaling_group.udit-asg.name
  policy_type = "SimpleScaling"
}

# creating alarm 
resource "aws_cloudwatch_metric_alarm" "udit-alarm" {
  alarm_name          = "udit-asg-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ApplicationELB"   # kisse monitor krna h
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.udit-asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.udit-policy.arn]
} 