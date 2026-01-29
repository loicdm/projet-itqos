terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://loicdm@192.168.1.199/system"
}

############################
# Isolated network
############################

resource "libvirt_network" "edge" {
  name      = "edge-10"
  autostart = true

  bridge = {
    name = "virbr-edge-10"
  }
}

############################
# Disk volume
############################

resource "libvirt_volume" "disk" {
  name     = "edge-10.qcow2"
  pool     = "default"
  capacity = 10 * 1024 * 1024 * 1024
}

############################
# Domain
############################

resource "libvirt_domain" "vyos" {
  name   = "edge-10"
  memory = 1024
  memory_unit = "MiB"
  vcpu   = 2
  type   = "kvm"

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [
      { dev = "cdrom" },
      { dev = "hd" }
    ]
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            volume_id = libvirt_volume.disk.id
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },
      {
        source = {
          file = {
            file = "/var/lib/libvirt/images/vyos.iso"
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
        readonly = true
      }
    ]

    interfaces = [
      {
        model = { type = "virtio" }
        source = {
          network = { network = "internet" }
        }
      },
      {
        model = { type = "virtio" }
        source = {
          network = { network = libvirt_network.edge.name }
        }
      }
    ]

    graphics = [
      {
        type = "spice"
        listen = {
          type    = "address"
          address = "0.0.0.0"
        }
      }
    ]

    video = [
      {
        model = { type = "qxl" }
      }
    ]

    consoles = [
      {
        type = "pty"
        target = {
          type = "serial"
          port = "0"
        }
      }
    ]
  }
}
