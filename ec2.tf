data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "Bastion" {
  ami                   = data.aws_ami.ubuntu.id
  instance_type         = "t2.micro"
  subnet_id             = module.vpc.public_subnets [0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name = "devops"
  
  tags = {
    Name = "Bastion"
  }
}
resource "aws_instance" "CI_CD-instance" {
  ami                   = data.aws_ami.ubuntu.id
  instance_type         = "t2.micro"
  subnet_id             = module.vpc.private_subnets [0]
  associate_public_ip_address = false
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name = "devops"
  
  tags = {
    Name = "CI/CD-instance"
  }
}

resource "aws_db_instance" "my_db_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  username             = "username"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [module.security_group.security_group_id]
  db_subnet_group_name = aws_db_subnet_group.default.id
  tags = {
    Name = "my_db_instance"
  }
}
