packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# ==========================
# Variables
# ==========================

variable "proxmox_url" {
  type    = string
  default = "https://192.168.10.250:8006/api2/json"
}

variable "proxmox_username" {
  type    = string
  default = "root@pam"
}

variable "proxmox_password" {
  type      = string
  default   = "h5ctK8EnGPLpVBv3pMhx2NEXvvkPan7n"
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "node1"
}

variable "iso_file" {
  type    = string
  default = "Backup-Node1:iso/ubuntu-24.04.3-live-server-amd64.iso"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
  sensitive = true
}

# ==========================
# Source VM
# ==========================

source "proxmox-iso" "ubuntu-server" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  vm_name = "ubuntu-24-04-template-packer"
  vm_id   = 999

  iso_file         = var.iso_file
  iso_storage_pool = "local"
  unmount_iso      = true

  memory   = 2048
  cores    = 2
  sockets  = 1
  cpu_type = "host"

  scsi_controller = "virtio-scsi-pci"
  disks {
    type         = "scsi"
    disk_size    = "32G"
    storage_pool = var.storage_pool
    format       = "raw"
  }

  network_adapters {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = false
  }

  cloud_init              = true
  cloud_init_storage_pool = var.storage_pool

  # Boot automatique (Ubuntu 24.04)
boot_command = [
  "<esc><wait>",
  "e<wait>",
  "<down><down><down><end>",
  " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
  "<f10><wait>"
]


  boot_wait   = "6s"
  communicator = "ssh"

  http_directory  = "./http"
  http_port_min   = 8098
  http_port_max   = 8098

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "30m"
  ssh_pty      = true
  ssh_handshake_attempts = 15
}

# ==========================
# Build
# ==========================

build {
  name    = "pkr-ubuntu-jammy-1"
  sources = ["source.proxmox-iso.ubuntu-server"]

  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  provisioner "shell" {
    execute_command = "echo -e '<user>' | sudo -S -E bash '{{ .Path }}'"
    inline = [
      "echo 'Clean'",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync",
      "echo 'Done Stage: Provisioning the VM Template for Cloud-Init Integration in Proxmox'"
    ]
  }
}
