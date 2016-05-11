// Bronze - A standard library for Swift.
// Copyright (C) 2015-2016  Take Vos
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

class SocketAddress : CustomStringConvertible {
    let sa: UnsafeMutablePointer<sockaddr>

    var length: Int {
        return Int(sa.memory.sa_len)
    }

    var family: Int32 {
        return Int32(sa.memory.sa_family)
    }

    var port: UInt16 {
        switch (family) {
        case AF_INET:
            let sa_in = UnsafeMutablePointer<sockaddr_in>(self.sa)
            return UInt16(bigEndian: sa_in.memory.sin_port)
        default:
            preconditionFailure("Ports are only available for socket families AF_INET, AF_INET6")
        }
    }

    var address: [UInt8] {
        switch (family) {
        case AF_INET:
            let sa_in = UnsafeMutablePointer<sockaddr_in>(self.sa)
            let addressNative = UInt32(bigEndian: sa_in.memory.sin_addr.s_addr)

            return [
                UInt8(addressNative >> 24 & 0xff),
                UInt8(addressNative >> 16 & 0xff),
                UInt8(addressNative >>  8 & 0xff),
                UInt8(addressNative       & 0xff)
            ]

        case AF_INET6:
            let sa_in6 = UnsafeMutablePointer<sockaddr_in6>(self.sa)
            let addressNative = sa_in6.memory.sin6_addr.__u6_addr.__u6_addr8

            return [
                addressNative.0, addressNative.1, addressNative.2, addressNative.3,
                addressNative.4, addressNative.5, addressNative.6, addressNative.7,
                addressNative.8, addressNative.9, addressNative.10, addressNative.11,
                addressNative.12, addressNative.13, addressNative.14, addressNative.15,
            ]

        case AF_UNIX:
            let sa_un = UnsafeMutablePointer<sockaddr_un>(self.sa)
            let addressNative = sa_un.memory.sun_path

            let mirror = Mirror(reflecting: addressNative)
            var path_array = Array<UInt8>()
            for (_, value) in mirror.children {
                switch value {
                case is UInt8:
                    let value_UInt8 = value as! UInt8
                    path_array.append(value_UInt8)

                    if value_UInt8 == 0 {
                        break
                    }
                default:
                    preconditionFailure()
                }
            }

            return path_array

        default:
            preconditionFailure("Addresses are only available for socket families AF_INET, AF_INET6")
        }
    }


    var addressString: String {
        switch (family) {
        case AF_INET:
            let addressStringArray = address.map{ String($0) }
            return addressStringArray.joinWithSeparator(".")

        case AF_INET6:
            var UInt16Address = Array<UInt16>()
            for i in 0 ..< (address.count / 2) {
                let tmp = (UInt16(address[i]) << 8) | UInt16(address[0])
                UInt16Address.append(tmp)
            }

            var listOfZeroRuns = Array<Int>()
            var zeroRun = 0
            for addressComponent in UInt16Address {
                if addressComponent == 0 {
                    zeroRun += 1

                } else {
                    if zeroRun > 0 {
                        listOfZeroRuns.append(zeroRun)
                    }
                    zeroRun = 0
                }
            }
            if zeroRun > 0 {
                listOfZeroRuns.append(zeroRun)
            }

            if listOfZeroRuns.count > 0 {
                var largestZeroRun_index = -1
                var largestZeroRun_size = 0

                for (i, zeroRun) in listOfZeroRuns.enumerate() {
                    if zeroRun > largestZeroRun_size {
                        largestZeroRun_index = i
                        largestZeroRun_size = zeroRun
                    }
                }

                let leftUInt16Address = UInt16Address[0 ..< largestZeroRun_index]
                let rightUInt16Address = UInt16Address[largestZeroRun_index + largestZeroRun_size ..< UInt16Address.count]

                let leftUint16AddressString = leftUInt16Address.map{ String($0, radix:16) }.joinWithSeparator(":")
                let rightUint16AddressString = rightUInt16Address.map{ String($0, radix:16) }.joinWithSeparator(":")
                return leftUint16AddressString + "::" + rightUint16AddressString

            } else {
                let addressStringArray = UInt16Address.map{ String($0, radix:16) }
                return addressStringArray.joinWithSeparator(":")
            }

        case AF_UNIX:
            return String(UTF8String: UnsafePointer<Int8>(address))!

        default:
            preconditionFailure("Addresses are only available for socket families AF_INET, AF_INET6")
        }

    }

    var description: String {
        switch (family) {
        case AF_INET:
            return "\(addressString):\(port)"
        case AF_INET6:
            return "[\(addressString)]:\(port)"
        case AF_UNIX:
            return "\(addressString)"

        default:
            preconditionFailure("socket family must be AF_INET, AF_INET6 or AF_UNIX")
        }
    }

    init() {
        let size = max(sizeof(sockaddr_in), sizeof(sockaddr_in6), sizeof(sockaddr_un))
        self.sa = UnsafeMutablePointer<sockaddr>(malloc(size))
        memset(UnsafeMutablePointer<UInt8>(self.sa), 0, size)
    }

    /// This initializer will copy the internal memory to the minimum size.
    init(_ socketAddress: SocketAddress) {
        self.sa = UnsafeMutablePointer<sockaddr>(malloc(socketAddress.length))
        memcpy(UnsafeMutablePointer<UInt8>(self.sa), UnsafeMutablePointer<UInt8>(socketAddress.sa), socketAddress.length)
    }

    init(ipv4Address: [UInt8], portNumber: UInt16) {
        precondition(ipv4Address.count == 4)

        self.sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_in)))
        memset(UnsafeMutablePointer<UInt8>(self.sa), 0, sizeof(sockaddr_in))

        let sa_in = UnsafeMutablePointer<sockaddr_in>(self.sa)
        sa_in.memory.sin_len = UInt8(sizeof(sockaddr_in))
        sa_in.memory.sin_family = UInt8(AF_INET)
        sa_in.memory.sin_port = portNumber.bigEndian
        sa_in.memory.sin_addr.s_addr = (
            (UInt32(ipv4Address[0]) << 24) |
            (UInt32(ipv4Address[1]) << 16) |
            (UInt32(ipv4Address[2]) <<  8) |
            UInt32(ipv4Address[3])
        ).bigEndian
    }

    init(ipv6Address: [UInt8], portNumber: UInt16) {
        precondition(ipv6Address.count == 16)

        self.sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_in6)))
        memset(UnsafeMutablePointer<UInt8>(self.sa), 0, sizeof(sockaddr_in6))

        let sa_in6 = UnsafeMutablePointer<sockaddr_in6>(self.sa)
        sa_in6.memory.sin6_len = UInt8(sizeof(sockaddr_in6))
        sa_in6.memory.sin6_family = UInt8(AF_INET6)
        sa_in6.memory.sin6_port = portNumber.bigEndian
        sa_in6.memory.sin6_addr.__u6_addr.__u6_addr8 = (
            ipv6Address[0], ipv6Address[1], ipv6Address[2], ipv6Address[3],
            ipv6Address[4], ipv6Address[5], ipv6Address[6], ipv6Address[7],
            ipv6Address[8], ipv6Address[9], ipv6Address[10], ipv6Address[11],
            ipv6Address[12], ipv6Address[13], ipv6Address[14], ipv6Address[15]
        )
    }

    init(unixPath: String) {
        self.sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_un)))
        memset(UnsafeMutablePointer<UInt8>(self.sa), 0, sizeof(sockaddr_un))

        let sa_un = UnsafeMutablePointer<sockaddr_un>(self.sa)
        sa_un.memory.sun_len = UInt8(sizeof(sockaddr_un))
        sa_un.memory.sun_family = UInt8(AF_UNIX)

        // Copy the path into an UTF8 character array, terminated with zero. Which is why the utf8 string
        // needs to be one less than the size of sun_path.
        precondition(unixPath.utf8.count < sizeofValue(sa_un.memory.sun_path) - 1)
        var path_array = Array<UInt8>(count: sizeofValue(sa_un.memory.sun_path), repeatedValue: 0)
        for (i, c) in unixPath.utf8.enumerate() {
            path_array[i] = c
        }

        // Assign the array to the int8-tupple. We first make a var path_tmp which has the right type, so we
        // can modify its memory, then assign it back.
        var path_tuple = sa_un.memory.sun_path
        memcpy(&path_tuple, path_array, path_array.count)
        sa_un.memory.sun_path = path_tuple
    }

    convenience init?(_ addressString: String) {
        precondition(addressString.characters.count > 0)
        
        if addressString.hasPrefix("/") {
            self.init(unixPath: addressString)

        } else if addressString.hasPrefix("[") {
            // Split the IP address and port number.
            let addressPortString = addressString.split("]:")
            guard addressPortString.count == 2 else {
                return nil
            }

            let addressString = addressPortString[0]
            let portString = addressPortString[1]

            guard let port = UInt16(portString, radix:10) else {
                return nil
            }

            // Split the IP address by at most 8 parts.
            let compressedAddressPartStrings = addressString.substringFromIndex(1).split(":")

            var bytes = Array<UInt8>()
            var foundEmptyPart = false
            for part in compressedAddressPartStrings {
                if part == "" {
                    // Only zero or one empty parts are allowed.
                    guard !foundEmptyPart else {
                        return nil
                    }
                    foundEmptyPart = true

                    // The number of parts except this part are the number of filled in parts.
                    let nrFilledInParts = compressedAddressPartStrings.count - 1
                    let zeroRun = 8 - nrFilledInParts

                    guard zeroRun >= 1 else {
                        return nil
                    }

                    // Replace the empty part with the zeros.
                    for _ in 0 ..< zeroRun {
                        bytes.append(0)
                        bytes.append(0)
                    }
                } else {
                    // Convert the hex string into bytes.
                    guard let part_UInt16 = UInt16(part, radix:16) else {
                        return nil
                    }

                    bytes.append(UInt8((part_UInt16 >> 8) & 0xff))
                    bytes.append(UInt8(part_UInt16 & 0xff))
                }
            }

            guard bytes.count == 16 else {
                return nil
            }

            self.init(ipv6Address: bytes, portNumber: port)

        } else {
            let addressPortString = addressString.split(":")
            let addressString = addressPortString[0]
            let portString = addressPortString[1]

            var bytes = Array<UInt8>()
            for part in addressString.substringFromIndex(1).split(".") {
                guard let byte = UInt8(part, radix:10) else {
                    return nil
                }
                bytes.append(byte)
            }

            guard bytes.count == 4 else {
                return nil
            }

            guard let port = UInt16(portString, radix:10) else {
                return nil
            }

            self.init(ipv4Address: bytes, portNumber: port)
        }

    }

    deinit {
        free(self.sa)
    }
}