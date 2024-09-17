#!/bin/bash
sudo apt update
sudo apt install docker.io gnupg -y
sudo apt install apt-transport-https curl -y
sudo systemctl enable docker
sudo systemctl start docker

sleep 6


### DOWNLOAD KEY


	
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#sudo echo deb http://apt.kubernetes.io/ kubernetes-xenial main   >> /etc/apt/sources.list.d/kubernetes.list
	
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
sudo mv ~/kubernetes.list /etc/apt/sources.list.d

sduo rm  /etc/apt/sources.list.d/eks-ppa.list 
sudo apt update

sudo apt-get install kubeadm kubelet kubectl -y

sudo apt-mark hold kubeadm kubelet kubectl

sudo swapoff –a

sudo hostnamectl set-hostname master-node

sudo hostnamectl set-hostname w1

sudo kubeadm init --pod-network-cidr=10.244.0.0/16




mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



	
sudo apt-get install -y kubernetes-cni

alias k=kubectl

### Deploy NETWORK Flannel
sudo /usr/local/bin/kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml






#sudo apt upgrade -y
