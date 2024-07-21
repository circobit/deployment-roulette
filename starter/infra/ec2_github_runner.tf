resource "aws_iam_instance_profile" "runner_instance_profile" {
  name = "runner-instance-profile"
  role = aws_iam_role.github_actions_role.name
}

resource "aws_security_group" "ssh_access_gitlab_runner" {
  name        = "ssh-access-gitlab-runner"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

      description     = ""
      from_port       = 22
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 22
    },
  ]

  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

      description     = ""
      from_port       = 80
      to_port         = 80
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]

      description     = ""
      from_port       = 443
      to_port         = 443
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
    },
  ]

  tags = {
    Name = "ssh_access"
  }
}

resource "aws_instance" "gh-runner" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.micro"
  key_name               = var.private_key
  user_data              = data.template_file.script.rendered
  iam_instance_profile   = aws_iam_instance_profile.runner_instance_profile.name
  vpc_security_group_ids = [aws_security_group.ssh_access_gitlab_runner.id]
  subnet_id              = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "udacity-github-self-hosted-runner"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }
}