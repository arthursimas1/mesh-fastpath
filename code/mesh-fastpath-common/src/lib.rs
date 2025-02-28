#![no_std]

#[repr(C, packed)]
#[derive(Copy, Clone)]
pub struct SockPairTuple {
    pub local_ip: [u32; 4usize],
    pub local_port: u16,

    pub remote_ip: [u32; 4usize],
    pub remote_port: u16,
}

// see: https://github.com/torvalds/linux/blob/master/include/linux/socket.h
pub enum IpAddrKind {
    V4 = 2,  // AF_INET
    V6 = 10, // AF_INET6
}

#[derive(Copy, Clone, PartialEq)]
pub enum SockSide {
    Client,
    Server,
}

#[repr(C, packed)]
#[derive(Copy, Clone)]
pub struct SockId {
    pub side: SockSide,
    pub ip: [u32; 4usize],
    pub port: u16,
}

// IPv4 mapped IPv6
// ::ffff:xy:zw = x.y.z.w
