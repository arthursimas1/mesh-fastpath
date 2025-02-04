resource "lxd_volume" "homelab_data" {
  name = "homelab-data"
  pool = lxd_storage_pool.btrfs_pool_default.name

  config = {
    #size = "20GiB"
  }
}

resource "lxd_instance" "monitoring" {
  name  = "monitoring"
  image = "ubuntu:22.04"
  type  = "virtual-machine"

  running = true

  limits = {
    cpu = 2
    memory = "2GiB"
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = lxd_storage_pool.btrfs_pool_default.name
      #source = lxd_volume.volume1.name
      path = "/"
      size = "40GiB"
    }
  }

  device {
    type = "disk"
    name = "data"

    properties = {
      pool = lxd_storage_pool.btrfs_pool_default.name
      source = lxd_volume.homelab_data.name
      path = "/mnt"
      #size = "10GiB"
    }
  }

  config = {
    "boot.autostart" = true
    "user.user-data" = data.cloudinit_config.k8s.rendered
  }

  profiles = [
    #lxd_profile.private_net.name,
    lxd_profile.public_net.name,
    #lxd_profile.wg_net.name,
  ]
}
