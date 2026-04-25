packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }    
  }
}

variable "region" {
  default = "eu-central-1"
}

source "amazon-ebs" "mariadb" {
  region                  = var.region
  instance_type           = "t3.micro"
  ami_name                = "mariadb-golden-{{timestamp}}"
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  communicator         = "ssh"
  ssh_username         = "ubuntu"
  ssh_interface        = "public_ip"
}

build {
  sources = ["source.amazon-ebs.mariadb"]

  provisioner "ansible" {
    command = "ansible-playbook"
    playbook_file = "/etc/ansible/playbooks/packer/configure_mariadb.yml"
    ansible_env_vars =  ["PACKER_BUILD_NAME={{ build_name }}"]
    inventory_file_template = "controller ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }}\n"
    use_proxy = false
  }
}