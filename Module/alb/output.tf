output "lb_id" {
  value = aws_lb.app_lb.id
}

output "tg_1_id" {
  value = aws_lb_target_group.tg_1.id
}

output "tg_2_id" {
  value = aws_lb_target_group.tg_2.id
}