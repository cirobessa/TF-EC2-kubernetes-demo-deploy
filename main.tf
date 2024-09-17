provider "aws" {
  region = "us-east-1"
  #  region = terraform.workspace == "default" ? "us-east-1" : "us-west-2"
  access_key    = var.AWS_ACCESS_KEY_ID
  secret_key    = var.AWS_SECRET_ACCESS_KEY
}

#data "aws_ssm_parameter" "ami_id" {
#  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#}



module "kubecluster" {
  source    = "./kubecluster"
  kubecname = "cluster01"

}


