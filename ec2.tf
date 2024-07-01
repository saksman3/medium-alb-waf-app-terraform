
# Create Jump-box instances
resource "aws_instance" "bastion_host" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = element(aws_subnet.public_subnet[*].id, 0)
  vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]
  key_name                    = aws_key_pair.bastion_ssh_keypair.key_name
  associate_public_ip_address = true
  tags = {
    Name = "${var.env}-bastion-host"
  }
}

resource "aws_security_group" "bastion_host_sg" {
  name        = "${var.env}-bastion-host-sg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # You can change this to only allow your IP address to SSH in
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


###### APP EC2 Instances ########################
resource "aws_instance" "medium_app" {
 count                        = var.ec2_instance_count_medium_app
  ami                         = var.ec2_ami
  iam_instance_profile        = aws_iam_instance_profile.medium_app_iam_role.name
  instance_type               = var.ec2_instance_type
  subnet_id                   = element(aws_subnet.private_subnet[*].id, count.index)
  vpc_security_group_ids      = [aws_security_group.medium_app_sg.id]
  key_name                    = aws_key_pair.ssh_keypair.key_name
  associate_public_ip_address = false
  tags = {
    Name = "${local.name}-instance"
  }
  ##### REMOTE PROVISIONER TO INSTALL PACKAGES #######
    provisioner "file" {
    source      = "~/.aws/credentials"
    destination = "/home/ubuntu/.aws/credentials"
    
    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = file("~/.ssh/id_rsa_github")
      host                = self.private_ip
      bastion_host        = aws_instance.bastion_host.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file("~/.ssh/medium-dev-key")
    }
  }
  #Install Docker and start the container
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y jq unzip curl",
      "curl -O https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip",
      "unzip awscli-exe-linux-x86_64.zip",
      "sudo ./aws/install",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "sudo sh get-docker.sh",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "sudo snap refresh amazon-ssm-agent",
      # "aws configure set aws_access_key_id access_key_id",
      # "aws configure set aws_secret_access_key access_key_sec",
      # "aws configure set default.region us-east-1"
    ]
    connection {
      type                  = "ssh"
      user                  = "ubuntu"  # Adjust based on your AMI's default user
      private_key           = file("~/.ssh/id_rsa_github")
      host                  = self.private_ip
      bastion_host          = aws_instance.bastion_host.public_ip
      bastion_user          = "ubuntu"
      bastion_private_key   = file("~/.ssh/medium-dev-key")
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      volume_tags
    ]
  }
}
resource "aws_key_pair" "ssh_keypair" {
  key_name   = "${var.env}-private-instance-keypair"  # Replace with your desired key pair name
  public_key = file("~/.ssh/id_rsa_github.pub")  # Replace with the path to your public key file
}
resource "aws_key_pair" "bastion_ssh_keypair" {
  key_name   = "${var.env}-bastion-keypair"  # Replace with your desired key pair name
  public_key = file("~/.ssh/medium-dev-key.pub")  # Replace with the path to your public key file
}
