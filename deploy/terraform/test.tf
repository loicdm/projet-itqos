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
