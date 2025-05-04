#!/bin/bash

set -e

# Set desired version or leave empty for latest
ANSIBLE_VERSION="$1"  # Usage: ./ansible.sh 2.10.7

echo "Installing Python and pip..."

# Install Python & pip depending on the OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS"
    exit 1
fi

install_python_pip() {
    if [[ "$OS" =~ (ubuntu|debian) ]]; then
        sudo apt update
        sudo apt install -y python3 python3-pip
        echo "Python version: $(python3 --version)"
        echo "pip version: $(pip3 --version)"
    elif [[ "$OS" =~ (centos|rocky|rhel|fedora) ]]; then
        sudo dnf install -y python3 python3-pip
        echo "pip version: $(pip3 --version)"
        echo "Python version: $(python3 --version)"
    else
        echo "Unsupported OS for Python installation."
        exit 2
    fi
}

install_ansible_with_pip() {
    pip3 install --upgrade pip
    if [ -z "$ANSIBLE_VERSION" ]; then
        echo "Installing latest Ansible..."
        pip3 install ansible
    else
        echo "Installing Ansible version $ANSIBLE_VERSION ..."
        pip3 install ansible=="$ANSIBLE_VERSION"
    fi
}

install_python_pip
install_ansible_with_pip

echo "Ansible installation complete:"
ansible --version
echo "Ansible version: $(ansible --version | head -n 1)"
