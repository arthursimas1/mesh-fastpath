/*resource "lxd_network" "lxdbr0" {
  name = "lxdbr0"

  type = "bridge"

  config = {
    #"ipv4.address" = "10.150.19.1/24"
    "ipv4.address" = "192.168.3.1/24"
    "ipv4.nat"     = "true"
    #"ipv6.address" = "fd42:474b:622d:259d::1/64"
    #"ipv6.nat"     = "true"
    #"ipv4.address" = "auto"
    "ipv6.address" = "none"
  }
}*/

/*resource "lxd_network" "wgbr0" {
  name = "wgbr0"

  type = "bridge"

  config = {
    "ipv4.address" = "192.168.2.3/24"
    #"ipv4.address" = "10.149.19.1/24"
    #"ipv4.nat"     = "false"
    #"ipv4.routes" = "192.168.2.0/24"
    #"ipv6.address" = "fd42:474b:622d:259d::1/64"
    #"ipv6.nat"     = "true"
    #"ipv4.address" = "auto"
    #"ipv6.address" = "none"
    #"bridge.external_interfaces" = "wg0"
    #parent = "wg0"
  }
}*/

/*resource "lxd_network" "lxdmacvlan0" {
  name = "lxdmacvlan0"

  type = "macvlan"

  config = {
    "parent" = "enp6s0"
  }
}*/

resource "lxd_storage_pool" "dir_pool_default" {
  name   = "dir_pool_default"
  driver = "dir"
  config = {
    #source = "/lxd-store"
  }
}

### profiles ###
# private = private network
# public  = public network

resource "lxd_profile" "private_net" {
  name = "private_net"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      #network = lxd_network.lxdbr0.name
      nictype = "bridged"
      parent  = "lxdbr0"
      #"ipv4.address" = "192.168.3.2"
    }
  }
}

/*resource "lxd_network_zone" "zone" {
  name = "custom.example.org"

  config = {
  }
}

resource "lxd_network_zone_record" "record" {
  name = "ns"
  zone = lxd_network_zone.zone.name

  entry {
    type = "A"
    value = "<lxd.host.ip>"
    ttl = 30
  }
}*/

/*resource "lxd_profile" "public_net" {
  name = "public_net"

  device {
    name = "eth0"
    type = "nic"

    properties = {
      network = lxd_network.lxdmacvlan0.name
    }
  }
}*/

/*resource "lxd_profile" "wg_net" {
  name = "wg_net"

  device {
    name = "wg0"
    type = "nic"

    properties = {
      network = lxd_network.wgbr0.name
    }
  }
}*/
