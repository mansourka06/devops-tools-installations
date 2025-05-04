#!/bin/bash

# This script installs Minikube and kubectl on an Ubuntu system.
# It also installs Docker as the container runtime for Minikube.

# Update the package index
sudo apt update -y
# Install the necessary dependencies
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
sudo apt install -y conntrack #this package monitors and keeps track of the state of k8s network connections

###############
#Install Docker
###############
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" -y
apt-cache policy docker-ce -y
sudo apt install docker-ce -y
sudo usermod -aG docker $USER && newgrp docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client  #display kubectl installed version

###################
# Install Minikube
###################
# Download the latest Minikube release
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
sudo minikube config set driver docker
minikube start --driver=docker 		# Start Minikube
kubectl config use-context minikube 	# Setup Minikube context
echo "Minikube installation complete."
minikube version  # Verify Minikube installation