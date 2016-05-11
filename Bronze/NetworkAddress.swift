//
//  NetworkAddress.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-30.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public enum NetworkAddress {
case IPv4Address([UInt8], UInt16)
case IPv6Address([UInt8], UInt16)
case UNIXAddress(String)

    init(sa: UnsafePointer<sockaddr>) {
        switch (sa.memory.sa_family) {
        case UInt8(AF_INET):
            let sa_in = UnsafePointer<sockaddr_in>(sa)
            let address = UInt32(bigEndian: sa_in.memory.sin_addr.s_addr)

            self = IPv4Address(
                [
                    UInt8((address >> 24) & 0xff),
                    UInt8((address >> 16) & 0xff),
                    UInt8((address >>  8) & 0xff),
                    UInt8((address >>  0) & 0xff)
                ],
                UInt16(bigEndian: sa_in.memory.sin_port)
            )

        case UInt8(AF_INET6):
            let sa_in6 = UnsafePointer<sockaddr_in6>(sa)
            let address = sa_in6.memory.sin6_addr.__u6_addr.__u6_addr8

            self = IPv6Address(
                [
                    address.0, address.1, address.2, address.3,
                    address.4, address.5, address.6, address.7,
                    address.8, address.9, address.10, address.11,
                    address.12, address.13, address.14, address.15,
                ],
                UInt16(bigEndian: sa_in6.memory.sin6_port)
            )

        case UInt8(AF_UNIX):
            let sa_un = UnsafePointer<sockaddr_un>(sa)
            var path_tuple = sa_un.memory.sun_path

            let path_string = withUnsafePointer(&path_tuple) {
                String(UTF8String: UnsafePointer($0))!
            }

            self = UNIXAddress(path_string)

        default:
            preconditionFailure("Expect a sockaddr family AF_INET, AF_INET6 or AF_UNIX")
        }
    }

    // socketAddress returns an allocated struct; use deallocSocketAddress() to dealloc.
    var socketAddress: UnsafeMutablePointer<sockaddr> {
        switch self {
        case .IPv4Address(let address, let port):
            let address_int = (
                UInt32(address[0]) << 24 |
                UInt32(address[1]) << 16 |
                UInt32(address[2]) <<  8 |
                UInt32(address[3])
            ).bigEndian

            let sa_in = UnsafeMutablePointer<sockaddr_in>.alloc(1)
            memset(sa_in, 0, sizeof(sockaddr_in))
            sa_in.memory.sin_len = UInt8(sizeof(sockaddr_in))
            sa_in.memory.sin_family = UInt8(AF_INET)
            sa_in.memory.sin_port = port.bigEndian
            sa_in.memory.sin_addr.s_addr = address_int
            return UnsafeMutablePointer<sockaddr>(sa_in)

        case .IPv6Address(let address, let port):
            let sa_in6 = UnsafeMutablePointer<sockaddr_in6>.alloc(1)
            memset(sa_in6, 0, sizeof(sockaddr_in6))
            sa_in6.memory.sin6_len = UInt8(sizeof(sockaddr_in6))
            sa_in6.memory.sin6_family = UInt8(AF_INET6)
            sa_in6.memory.sin6_port = port.bigEndian
            sa_in6.memory.sin6_addr.__u6_addr.__u6_addr8 = (
                address[0], address[1], address[2], address[3],
                address[4], address[5], address[6], address[7],
                address[8], address[9], address[10], address[11],
                address[12], address[13], address[14], address[15]
            )
            return UnsafeMutablePointer<sockaddr>(sa_in6)

        case .UNIXAddress(let path):
            let sa_un = UnsafeMutablePointer<sockaddr_un>.alloc(1)
            memset(sa_un, 0, sizeof(sockaddr_un))
            sa_un.memory.sun_len = UInt8(sizeof(sockaddr_un))
            sa_un.memory.sun_family = UInt8(AF_UNIX)

            // Copy the path into an UTF8 character array, terminated with zero.
            precondition(path.utf8.count < sizeofValue(sa_un.memory.sun_path) - 1)
            var path_array = Array<UInt8>(count: sizeofValue(sa_un.memory.sun_path), repeatedValue: 0)
            for (i, c) in path.utf8.enumerate() {
                path_array[i] = c
            }

            // Assign the array to the int8-tupple. We first make a var path_tmp which has the right type, so we
            // can modify its memory, then assign it back.
            var path_tupple = sa_un.memory.sun_path
            memcpy(&path_tupple, path_array, path_array.count)
            sa_un.memory.sun_path = path_tupple

            return UnsafeMutablePointer<sockaddr>(sa_un)
        }
    }
}