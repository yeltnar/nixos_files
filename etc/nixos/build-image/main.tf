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


# resource "proxmox_virtual_environment_download_file" "nixos_qcow2" {

# resource "proxmox_virtual_environment_file" "ubuntu_container_template" {
resource "proxmox_virtual_environment_file" "nixos_qcow2" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "pve"

  source_file {
    path = "http://drew-lin-desktop.lan:9999/nixos-image-qcow2-25.11.20251206.d9bc5c7-x86_64-linux.qcow2"
  }
}

output "nixos_qcow2" {
  value = proxmox_virtual_environment_file.nixos_qcow2
}

# TODO need to 'import' file into lvm. dont want to directly boot from the qcow2 image

resource "proxmox_virtual_environment_vm" "my_vm" {
  name      = "opentofu-vm"
  node_name = "pve"
  vm_id     = 102

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


