provider "aws" {
  region = "us-east-1"
  #  region = terraform.workspace == "default" ? "us-east-1" : "us-west-2"
}

data "aws_ssm_parameter" "ami_id" {
  #  name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
  ##name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}




module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs                     = ["us-east-1a"]
  public_subnets          = ["10.0.1.0/24"]
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace}-vpc"
  }


}


resource "aws_security_group" "my-sg" {
  vpc_id = module.vpc.vpc_id
  name   = join("_", ["sg", module.vpc.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["eport"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Terraform-Dynamic-SG"
    Terraform = "Yes"
  }
}

resource "aws_instance" "my-instance" {
  ami = data.aws_ssm_parameter.ami_id.value
  #  ami             = data.aws_ami.ubuntu
  subnet_id            = module.vpc.public_subnets[0]
  instance_type        = "t3.medium"
  security_groups      = [aws_security_group.my-sg.id]
  iam_instance_profile = aws_iam_instance_profile.demo-profile.name
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 40
  }
  user_data = <<EOF
   #!/bin/bash
   curl  https://raw.githubusercontent.com/cirobessa/pri-rest-rb/master/script-install-kube-cluster-generic.sh | sudo bash -
   echo wait KUBEadmin to finish
   sleep 40
   echo Install the Calico network add-on
    export KUBECONFIG=/etc/kubernetes/admin.conf
     kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
     echo upload JOIN COMMAND to S3
     kubeadm token create --print-join-command > /tmp/join-command.sh
     aws s3 cp /tmp/join-command.sh s3://`hostname`/
   echo "
   mkdir -p $HOME/.kube
   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   sudo chown $(id -u):$(id -g) $HOME/.kube/config"  >> /etc/skel/.bash_profile 
EOF

  tags = {
    Name      = join("_", ["server", var.kubecname])
    Workspace = "${terraform.workspace}-MASTER-node"
  }
}


resource "aws_instance" "myvm" {
  ami = data.aws_ssm_parameter.ami_id.value
  #  ami             = data.aws_ami.ubuntu
  subnet_id            = module.vpc.public_subnets[0]
  instance_type        = "t3.small"
  security_groups      = [aws_security_group.my-sg.id]
  iam_instance_profile = aws_iam_instance_profile.demo-profile.name
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 40
  }
  count = terraform.workspace == "default" ? 2 : 3
  # (resource arguments)
  user_data = <<EOF
   #!/bin/bash
   curl  https://raw.githubusercontent.com/cirobessa/pri-rest-rb/master/script-WORKER-node.sh | sudo bash -
EOF


  tags = {
    Name = "${terraform.workspace}-Worker-node"
  }
}


