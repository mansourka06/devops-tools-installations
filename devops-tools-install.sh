#!/bin/bash

#########################################################
# Description: DevOps tools installation                #
# Supported OS: Debian | Ubuntu                         #
# Author: Mansour KA (mansourka.devops@protonmail.com)  #
# Last update: 10/12/2023                               #
#########################################################

#####################################################################################################################
# BDEGIN

IP=$(hostname -I | awk '{print $2}')

set -e 

# ENABLE/DESABLE INSTALL TOOLS : Supported value [ON, OFF]
ANSIBLE=ON
DOCKER=ON
JENKINS=OFF
MINIKUBE=OFF
TERRAFORM=OFF

# Check the system based Distribution
if [ -f /etc/debian_version ]; then
    echo "Detected a Debian-based distribution."
    # Update package list
    sudo apt update
    # some settings for common server
    sudo apt install -y -qq curl git net-tools gnupg software-properties-common tree telnet vim 2>&1 >/dev/null

## If the distribution is neither Red Hat-based nor Debian-based
else
    echo "Unsupported distribution. Only Debian-based OS are Support for this stack !"
    exit 1
fi

case $ANSIBLE in
    ON) # Install Ansible
      sudo apt-get -y install ansible sshpass
      echo "Ansible installation completed."
      ansible --version
      ;;
    OFF)
      echo "skip ansible installation"
      ;;
    *)
     echo "Only ON or OFF value is supported, for ansible install"
     ;;
esac

case $DOCKER in
    ON)
      # Check if Docker is installed
      if command -v docker &>/dev/null; then
        echo "Docker is already installed on $IP server"
        sudo usermod -aG docker $USER
        sudo systemctl enable docker
        sudo systemctl start docker
      else
        # install docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        sudo usermod -aG docker $USER
        sudo systemctl enable docker
        sudo systemctl start docker
        #install docker compose
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        echo "Docker installation completed."
      fi
      ;;
    OFF)
      echo "skip docker installation"
      ;;
    *)
     echo "Only ON or OFF value is supported, for docker install"
     ;;
esac

case $TERRAFORM in
    ON) # Install Terraform
      TERRAFORM_VERSION="0.14.7" # Change this to the desired Terraform version
      wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
      unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
      sudo mv terraform /usr/local/bin/
      rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
      ;;
    OFF)
      echo "skip Terraform installation"
      ;;
    *)
     echo "Only ON or OFF value is supported, for terraform install"
     ;;
esac

case $JENKINS in
    ON) # Install Jenkins
      sudo wget -O /etc/apt-get.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
      sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
      sudo apt install -y jenkins
      sudo systemctl start jenkins
      sudo systemctl enable jenkins
      ;;
    OFF)
      echo "skip jenkins installation"
      ;;
    *)
     echo "Only ON or OFF value is supported, for jenkins install"
     ;;
esac

# Minikube installation
case $MINIKUBE in
    ON)
      # Check if Docker is installed
      if ! command -v docker &>/dev/null; then
        echo "Docker is not installed. Minikube requires docker,Please enable (ON) Docker installation before continuing."
        exit 1
      else
        # Install the necessary dependencies
        sudo apt update && sudo apt install -y apt-transport-https ca-certificates software-properties-common
        sudo apt install -y conntrack #this package monitors and keeps track of the state of k8s network connections
        # Install kubectl
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        kubectl version --client  #display kubectl installed version
        # Install Minikube
        echo "Installing Minikube..."
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        sudo minikube config set driver docker
        minikube start --driver=docker 		#Start Minikube
        kubectl config use-context minikube 	#setup Minikube context
        echo "Minikube installation complete."
        minikube version  # Verify Minikube installation
      fi
      ;;
    OFF)
      echo "skip minikube installation"
      ;;
    *)
     echo "Only ON or OFF value is supported, for minikube install"
     ;;
esac

## Install zsh if needed
# To enable zsh: 
export ENABLE_ZSH="true" # comment this line if you don't want to install zsh

if [[ !(-z "$ENABLE_ZSH")  &&  ($ENABLE_ZSH == "true") ]]; then
  echo "Checking ZSH install directory"

  if [ -d "/home/$USER/.oh-my-zsh" ]; then
    echo "The ZSH install folder /home/$USER/.oh-my-zsh already exists."
  else
    echo "We are going to install zsh"
    sudo rm -rf /home/$USER/.oh-my-zsh
    sudo apt -y install zsh git
    echo "$USER" | chsh -s /bin/zsh $USER
    su - $USER  -c  'echo "Y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
    su - $USER  -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    sed -i 's/^plugins=/#&/' /home/$USER/.zshrc
    echo "plugins=(git  docker docker-compose colored-man-pages aliases copyfile  copypath dotenv zsh-syntax-highlighting jsontools)" >> /home/$USER/.zshrc
    sed -i "s/^ZSH_THEME=.*/ZSH_THEME='agnoster'/g"  /home/$USER/.zshrc
  fi
else
    echo "The zsh is not installed on this server"    
fi

echo "For this Stack, you will use $IP IP Address"

#END
#####################################################################################################################