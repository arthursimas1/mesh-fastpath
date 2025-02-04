/*resource "lxd_volume" "homelab_data" {
  name = "homelab-data"
  pool = lxd_storage_pool.btrfs_pool_default.name

  config = {
    #size = "20GiB"
  }
}*/

resource "lxd_instance" "workload-cilium-0" {
  name  = "workload-cilium-0"
  image = "ubuntu:24.04"
  type  = "virtual-machine"

  running = true

  limits = {
    cpu = 4
    memory = "8GiB"
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = lxd_storage_pool.dir_pool_default.name
      path = "/"
      #size = "40GiB"
    }
  }

  /*device {
    name = "eth0"
    type = "nic"

    properties = {
      #network = lxd_network.lxdbr0.name
      nictype = "bridged"
      parent  = lxd_network.lxdbr0.name
      #"ipv4.address" = "192.168.3.2"
    }
  }*/

  /*device {
    type = "disk"
    name = "data"

    properties = {
      pool = lxd_storage_pool.btrfs_pool_default.name
      source = lxd_volume.homelab_data.name
      path = "/mnt"
      #size = "10GiB"
    }
  }*/

  config = {
    "boot.autostart" = true
    "user.user-data" = data.cloudinit_config.rke2_cilium.rendered
  }

  profiles = [
    lxd_profile.private_net.name,
    #lxd_profile.public_net.name,
    #lxd_profile.wg_net.name,
  ]
}
