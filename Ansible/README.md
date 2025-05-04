# Ansible installation

This is a bash script that installs Ansible on a Linux system.

## supported OS

- [x] Ubuntu
- [x] Debian
- [x] RedHat

## Usage

### 1. Create file `ansible-install.sh` and copy and paste the [ansible-install.sh](ansible-install.sh) script content.

 ```bash
 nano ansible-install.sh
 ```

---

### 2. Make it executable

 ```bash
 chmod +x ansible-install.sh
 ```

---

### 1. Run the script

- To install latest version:

 ```bash
 ./ansible-install.sh
 ```

- **To install a specific version (e.g., 2.10.7):**

 ```bash
 ./ansible-install.sh 2.10.7
 ```

> **NOTE**: By default, the script installs the latest version of Ansible. But we can also install a specific Ansible version by adding the desired version at the end of the script in the command line.