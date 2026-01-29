terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://libvirt@vmhost/system"
}

############################
# Isolated network
############################

resource "libvirt_network" "edge" {
  name      = "edge-10"
  autostart = true

  bridge {
    name = "virbr-edge-10"
  }
}

############################
# Volumes
############################

resource "libvirt_volume" "disk" {
  name   = "edge-10.qcow2"
  pool   = "default"
  capacity = 10 * 1024 * 1024 * 1024
}

resource "libvirt_volume" "iso" {
  name   = "vyos.iso"
  pool   = "default"
  source = "https://community-downloads.vyos.dev/stream/2025.11/vyos-2025.11-generic-amd64.iso"
}

############################
# Domain
############################

resource "libvirt_domain" "vm" {
  name   = "edge-10"
  type   = "kvm"
  memory = 1024
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.disk.id
  }

  disk {
    volume_id = libvirt_volume.iso.id
  }

  network_interface {
    network_name = "internet"
    model        = "virtio"
  }

  network_interface {
    network_id = libvirt_network.edge.id
    model      = "virtio"
  }

  graphics {
    type        = "spice"
    autoport    = true
    listen_type = "address"
  }

  video {
    type = "qxl"
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}
