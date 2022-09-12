# getting key with name = udit-public from aws 
data "aws_key_pair" "public"{
    key_name = "udit-public"
}

# taking default vpc id 
data "aws_vpc" "default" {
  default = true
}

# taking the ami id for launch configuration
data "aws_ami" "linux" {
   most_recent = true
   owners = ["707713643480"] 
   filter {
        name   = "name"
        values = ["udit-ami"]
    } 
}

# getting subnets in the vpc  data "aws_subnet_ids" "test_subnet_ids"
data "aws_subnet_ids" "subnet" {
  vpc_id = data.aws_vpc.default.id
}

# creating security group object
module "security_group" {
  source = "./Module/securit_group/"
  vpc-id = data.aws_vpc.default.id
}

# creating 3 ec2 insatnce in 3 different az subnets
module "elb_ec2_1" {
  source = "./Module/ec2"
  ec2-name = "udit_elb_ec2_1"
  key-name = data.aws_key_pair.public.key_name
  az="${element(var.az,0)}"
  public-ip = true
  sg=[module.security_group.sg_id]
}

module "elb_ec2_2" {
  source = "./Module/ec2"
  ec2-name = "udit_elb_ec2_2"
  key-name = data.aws_key_pair.public.key_name
  az="${element(var.az,0)}"
  public-ip = true
  sg=[module.security_group.sg_id]
}

module "elb_ec2_3" {
  source = "./Module/ec2"
  ec2-name = "udit_elb_ec2_3"
  key-name = data.aws_key_pair.public.key_name
  az="${element(var.az,1)}"
  public-ip = true
  sg=[module.security_group.sg_id]
}
module "elb_ec2_4" {
  source = "./Module/ec2"
  ec2-name = "udit_elb_ec2_4"
  key-name = data.aws_key_pair.public.key_name
  az="${element(var.az,1)}"
  public-ip = true
  sg=[module.security_group.sg_id]
}

# creating application load balancer, listner, target group
module "load_balancer" {
  source = "./Module/alb"
  sg = [module.security_group.sg_id]
  vpc-id = data.aws_vpc.default.id
  subnets = data.aws_subnet_ids.subnet.ids
  tg-ec-id = [module.elb_ec2_1.ec2-id , module.elb_ec2_2.ec2-id, module.elb_ec2_3.ec2-id, module.elb_ec2_4.ec2-id]
}

# creating ASG 
module "ASG" {
  source = "./Module/asg"
  sg = [module.security_group.sg_id]
  img-id = data.aws_ami.linux.id
  key-name = data.aws_key_pair.public.key_name
  subnets = data.aws_subnet_ids.subnet.ids
  targets = [module.load_balancer.tg_1_id, module.load_balancer.tg_2_id]
}