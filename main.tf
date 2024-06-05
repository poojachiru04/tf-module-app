resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}"
  description = "${var.name}-${var.env}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH Port"
  }

  ingress {
    from_port   = var.port_no
    to_port     = var.port_no
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description =
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


resource "aws_instance" "main" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  tags = {
    Name      = "${var.name}-${var.env}"
    Monitor   = "yes"
    env       = var.env
    component = var.name
  }


resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = "${var.name}-${var.env}.poodevops.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.main.private_ip]
}

resource "null_resource" "main" {
  depends_on = [aws_route53_record.main]
  provisioner "local-exec" {
    command = "sleep 120; cd /home/ec2-user/expense-ansible ; ansible-playbook -i $(aws_instance.node.private_ip), -e ansible_user=ec2-user -e ansible_password=DevOps321 -e role_name=$(var.name) -e env=dev expense.yml"
  }
}

