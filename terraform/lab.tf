variable "vm_config" {
  type = map(object({
    name               = string
    desc               = string
    cores              = number
    memory             = number
    clone              = string
    dns                = string
    ip                 = string
    gateway            = string
  }))

  default = {
    "dc01" = {
      name               = "GOAD-DC01"
      desc               = "DC01 - windows server 2019 - 192.168.10.10"
      cores              = 2
      memory             = 3096
      clone              = "WinServer2019_x64"
      dns                = "192.168.10.1"
      ip                 = "192.168.10.10/28"
      gateway            = "192.168.10.1"
    }
    "dc02" = {
      name               = "GOAD-DC02"
      desc               = "DC02 - windows server 2019 - 192.168.10.11"
      cores              = 2
      memory             = 3096
      clone              = "WinServer2019_x64"
      dns                = "192.168.10.1"
      ip                 = "192.168.10.11/28"
      gateway            = "192.168.10.1"
    }
    "srv02" = {
      name               = "GOAD-SRV02"
      desc               = "SRV02 - windows server 2019 - 192.168.10.22"
      cores              = 2
      memory             = 4096
      clone              = "WinServer2019_x64"
      dns                = "192.168.10.1"
      ip                 = "192.168.10.12/28"
      gateway            = "192.168.10.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "bgp" {
  for_each = var.vm_config

    name = each.value.name
    description = each.value.desc
    node_name   = var.pm_node
    pool_id     = var.pm_pool

    operating_system {
      type = "win10"
    }

    cpu {
      cores   = each.value.cores
      sockets = 1
    }

    memory {
      dedicated = each.value.memory
    }

    clone {
      vm_id = lookup(var.vm_template_id, each.value.clone, -1)
      full  = var.pm_full_clone
      retries = 2
    }

    agent {
      # read 'Qemu guest agent' section, change to true only when ready
      enabled = true
    }

    network_device {
      bridge  = var.network_bridge
      model   = var.network_model
      vlan_id = var.network_vlan
    }

    lifecycle {
      ignore_changes = [
        vga,
      ]
    }

    initialization {
      datastore_id = var.storage
      dns {
        servers = [
          each.value.dns
        ]
      }
      ip_config {
        ipv4 {
          address = each.value.ip
          gateway = each.value.gateway
        }
      }
    }
}
