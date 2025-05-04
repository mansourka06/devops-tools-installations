# Ansible installation

This is a bash script that installs Ansible on a Linux system.

## supported OS

- [x] Ubuntu
- [x] Debian
- [x] RedHat

## Usage

### 1. Create file `ansible.sh` and copy and paste the script content

 ```bash
 nano ansible.sh
 ```

 ```bash
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

 ```

---

### 2. Make it executable

 ```bash
 chmod +x ansible.sh
 ```

---

### 1. Run the script

- To install latest version:

 ```bash
 ./ansible.sh
 ```

- **To install a specific version (e.g., 2.10.7):**

 ```bash
 ./ansible.sh 2.10.7
 ```

> **NOTE**: By default, the script installs the latest version of Ansible. But we can also install a specific Ansible version by adding the desired version at the end of the script in the command line.