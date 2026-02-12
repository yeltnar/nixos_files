terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.94.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true

}

variable "proxmox_api_token" {
  type = string
}

variable "proxmox_endpoint" {
  type = string
}


# this is set from the .env.enc file... it expands the file off the disk
variable "image_name" {
  type = string
}

variable "image_proxmox_name" {
  type = string
}

# resource "proxmox_virtual_environment_file" "ubuntu_container_template" {
resource "proxmox_virtual_environment_file" "nixos_qcow2" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    # TODO make this pull not push
    path = "${var.image_name}"
    file_name = "${var.image_proxmox_name}.qcow2"
  }
}

resource "proxmox_virtual_environment_vm" "my_vm" {
  name      = "opentofu-vm-${var.image_proxmox_name}"
  node_name = "pve"
  # vm_id     = 102

  # # This block tells OpenTofu how to connect to the VM
  # connection {
  #   type     = "ssh"
  #   user     = "drew"
  #   host     = self.ipv4_addresses[0][0] # Adjust based on your network setup
  #   # private_key = file("~/.ssh/id_rsa")
  # }

  # provisioner "file" {
  #   source = "./date.txt"
  #   destination = "/home/drew/date.txt"
  # }

  agent {
    # Enables the QEMU Guest Agent
    enabled = true
    # Optional: Disconnects the agent when the VM is paused
    # use_fstrim = true 
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  # This attaches the uploaded qcow2 image as a disk
  disk {
    #   datastore_id = "local-lvm"
    # file_id      = proxmox_virtual_environment_file.nixos_qcow2.id
    import_from      = proxmox_virtual_environment_file.nixos_qcow2.id
    interface    = "virtio0"
    size         = 20 # Resize it if needed
  }

  # Make it the only bootable device
  boot_order = ["virtio0"]

  # Standard network setup
  network_device {
    bridge = "vmbr0"
  }
}

output "nixos_qcow2" {
  value = proxmox_virtual_environment_file.nixos_qcow2
}

# resource "proxmox_virtual_environment_vm" "my_vm" {
output "my_vm" {
  value = proxmox_virtual_environment_vm.my_vm
}

