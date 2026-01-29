provider "libvirt" {
  uri = "qemu+ssh://loicdm@192.168.1.199/system"
}

resource "libvirt_network" "edge" {
  name      = "edge-10"
  mode      = "isolated"
  bridge    = "virbr-edge-10"
  autostart = true
}

resource "libvirt_volume" "disk" {
  name   = "edge-10.qcow2"
  pool   = "default"
  size   = 10 * 1024 * 1024 * 1024
}

resource "libvirt_volume" "iso" {
  name   = "vyos.iso"
  pool   = "default"
  source = "https://community-downloads.vyos.dev/stream/2025.11/vyos-2025.11-generic-amd64.iso"
  format = "iso"
}

resource "libvirt_domain" "vm" {
  name   = "edge-10"
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
  }

  network_interface {
    network_id = libvirt_network.edge.id
  }

  graphics {
    type        = "spice"
    autoport    = true
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }
}
