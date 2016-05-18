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

public enum SocketAddress : CustomStringConvertible {
case IPv4([UInt8], UInt16)
case IPv6([UInt8], UInt16)
case UNIX(String)

    var length: UInt32 {
        switch self {
        case IPv4(_, _):
            return UInt32(sizeof(sockaddr_in))
        case IPv6(_, _):
            return UInt32(sizeof(sockaddr_in6))
        case UNIX(_):
            return UInt32(sizeof(sockaddr_un))
        }
    }

/*    var family: Int32 {
        switch self {
        case IPv4(_, _):
            return AF_INET
        case IPv6(_, _):
            return AF_INET6
        case UNIX(_):
            return AF_UNIX
        }
    }

    var port: UInt16 {
        switch self {
        case IPv4(_, let port):
            return port
        case IPv6(_, let port):
            return port
        default:
            preconditionFailure("Port is only for IPv4 and IPv6")
        }
    }

    var address: [UInt8] {
        switch self {
        case IPv4(let address, _):
            return address
        case IPv6(let address, _):
            return address
        case UNIX(let path):
            var address = Array<UInt8>()
            for c in path.utf8 {
                address.append(c)
            }
            return address
        }
    }*/

    var addressString: String {
        switch self {
        case IPv4(let address, _):
            let addressStringArray = address.map{ String($0) }
            return addressStringArray.joinWithSeparator(".")

        case IPv6(let address, _):
            var addressWords = Array<UInt16>()
            for i in 0 ..< (address.count / 2) {
                let word = (UInt16(address[(i*2)]) << 8) | UInt16(address[(i*2)+1])
                addressWords.append(word)
            }

            let longestRun = addressWords.longestRun(0)

            if longestRun.distance > 0 {
                let leftAddressWords = addressWords[addressWords.startIndex ..< longestRun.startIndex]
                let rightAddressWords = addressWords[longestRun.endIndex ..< addressWords.endIndex]

                let leftAddressString = leftAddressWords.map{ String($0, radix:16) }.joinWithSeparator(":")
                let rightAddressString = rightAddressWords.map{ String($0, radix:16) }.joinWithSeparator(":")
                return leftAddressString + "::" + rightAddressString

            } else {
                let addressStringArray = addressWords.map{ String($0, radix:16) }
                return addressStringArray.joinWithSeparator(":")
            }

        case UNIX(let path):
            return path
        }
    }

    public var description: String {
        switch self {
        case IPv4(_, let port):
            return "\(addressString):\(port)"
        case IPv6(_, let port):
            return "[\(addressString)]:\(port)"
        case UNIX(_):
            return "\(addressString)"
        }
    }

    var socketAddressIPv4: sockaddr_in {
        switch self {
        case IPv4(let address, let port):
            precondition(address.count == 4)

            let addr = in_addr(s_addr: (
                (UInt32(address[0]) << 24) |
                (UInt32(address[1]) << 16) |
                (UInt32(address[2]) <<  8) |
                UInt32(address[3])
            ).bigEndian)

            let sa = sockaddr_in(
                sin_len: UInt8(sizeof(sockaddr_in)),
                sin_family: UInt8(AF_INET),
                sin_port: port.bigEndian,
                sin_addr: addr,
                sin_zero: (0,0,0,0,0,0,0,0)
            )

            return sa
        default:
            preconditionFailure("Can only take IPv4 socket address.")
        }
    }

    var socketAddressIPv6: sockaddr_in6 {
        switch self {
        case IPv6(let address, let port):
            precondition(address.count == 16)

            var addr = in6_addr()
            addr.__u6_addr.__u6_addr8 = (
                address[0], address[1], address[2], address[3],
                address[4], address[5], address[6], address[7],
                address[8], address[9], address[10], address[11],
                address[12], address[13], address[14], address[15]
            )

            let sa = sockaddr_in6(
                sin6_len: UInt8(sizeof(sockaddr_in6)),
                sin6_family: UInt8(AF_INET6),
                sin6_port: port.bigEndian,
                sin6_flowinfo: 0,
                sin6_addr: addr,
                sin6_scope_id: 0
            )

            return sa
        default:
            preconditionFailure("Can only take IPv6 socket address.")
        }
    }

    var socketAddressUNIX: sockaddr_un {
        switch self {
        case UNIX(let path):
            var sa = sockaddr_un()
            sa.sun_len = UInt8(sizeof(sockaddr_un))
            sa.sun_family = UInt8(AF_UNIX)

            // Copy the path into an UTF8 character array, terminated with zero. Which is why the utf8 string
            // needs to be one less than the size of sun_path.
            precondition(path.utf8.count < sizeofValue(sa.sun_path) - 1)
            var path_array = Array<UInt8>(count: sizeofValue(sa.sun_path), repeatedValue: 0)
            for (i, c) in path.utf8.enumerate() {
                path_array[i] = c
            }

            // Assign the array to the int8-tupple. We first make a var path_tmp which has the right type, so we
            // can modify its memory, then assign it back.
            var path_tuple = sa.sun_path
            memcpy(&path_tuple, path_array, path_array.count)
            sa.sun_path = path_tuple
            return sa

        default:
            preconditionFailure("Can only take UNIX socket path.")
        }
    }

    var unsafeSocketAddress: UnsafeMutablePointer<sockaddr> {
        switch self {
        case IPv4(_, _):
            let sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_in)))
            memset(UnsafeMutablePointer<UInt8>(sa), 0, sizeof(sockaddr_in))

            let sa_in = UnsafeMutablePointer<sockaddr_in>(sa)
            sa_in.memory = socketAddressIPv4
            return sa

        case IPv6(_, _):
            let sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_in6)))
            memset(UnsafeMutablePointer<UInt8>(sa), 0, sizeof(sockaddr_in6))

            let sa_in6 = UnsafeMutablePointer<sockaddr_in6>(sa)
            sa_in6.memory = socketAddressIPv6
            return sa

        case UNIX(_):
            let sa = UnsafeMutablePointer<sockaddr>(malloc(sizeof(sockaddr_un)))
            memset(UnsafeMutablePointer<UInt8>(sa), 0, sizeof(sockaddr_un))

            let sa_un = UnsafeMutablePointer<sockaddr_un>(sa)
            sa_un.memory = socketAddressUNIX
            return sa
        }
    }

    init(family: Int32, port: UInt16 = 0) {
        switch family {
        case AF_INET:
            self = IPv4([0, 0, 0, 0], port)
        case AF_INET6:
            self = IPv6(Array<UInt8>(count: 16, repeatedValue: 0), port)
        default:
            preconditionFailure("Can only initialize AF_INET and AF_INET6 address with IN_ADDR_ANY")
        }
    }

    init(_ socketAddress: sockaddr_in) {
        let address = UInt32(bigEndian:socketAddress.sin_addr.s_addr)

        self = IPv4(
            [
                UInt8((address >> 24) & 0xff),
                UInt8((address >> 16) & 0xff),
                UInt8((address >>  8) & 0xff),
                UInt8( address        & 0xff)
            ],
            UInt16(bigEndian: socketAddress.sin_port)
        )
    }

    init(_ socketAddress: sockaddr_in6) {
        let address = socketAddress.sin6_addr.__u6_addr.__u6_addr8
        self = IPv6(
            [
                UInt8(address.0 ), UInt8(address.1 ), UInt8(address.2 ), UInt8(address.3 ),
                UInt8(address.4 ), UInt8(address.5 ), UInt8(address.6 ), UInt8(address.7 ),
                UInt8(address.8 ), UInt8(address.9 ), UInt8(address.10), UInt8(address.11),
                UInt8(address.12), UInt8(address.13), UInt8(address.14), UInt8(address.15)
            ],
            UInt16(bigEndian: socketAddress.sin6_port)
        )
    }

    init(_ socketAddress: sockaddr_un) {
        let addressMirror = Mirror(reflecting: socketAddress.sun_path)
        var pathBytes = Array<Int8>()

        for (_, anyValue) in addressMirror.children {
            let value = anyValue as! Int8
            if value == 0 {
                break
            }

            pathBytes.append(value)
        }
        pathBytes.append(0)

        self = UNIX(String(UTF8String: pathBytes)!)
    }

    init(_ socketAddress: UnsafeMutablePointer<sockaddr>) {
        switch Int32(socketAddress.memory.sa_family) {
        case AF_INET:
            self.init(UnsafeMutablePointer<sockaddr_in>(socketAddress).memory)
        case AF_INET6:
            self.init(UnsafeMutablePointer<sockaddr_in6>(socketAddress).memory)
        case AF_UNIX:
            self.init(UnsafeMutablePointer<sockaddr_un>(socketAddress).memory)
        default:
            preconditionFailure("Unknown family \(socketAddress.memory.sa_family)")
        }
    }

    init?(_ addressString: String) {
        precondition(addressString.characters.count > 0)
        
        if addressString.hasPrefix("/") {
            self = UNIX(addressString)

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

            self = IPv6(bytes, port)

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

            self = IPv4(bytes, port)
        }
    }

    static func newUnsafeSocketAddressLength() -> UInt32 {
        return UInt32(max(sizeof(sockaddr_in), sizeof(sockaddr_in6), sizeof(sockaddr_un)))
    }

    static func newUnsafeSocketAddress() -> UnsafeMutablePointer<sockaddr> {
        let sa = UnsafeMutablePointer<sockaddr>(malloc(Int(newUnsafeSocketAddressLength())))
        memset(UnsafeMutablePointer<UInt8>(sa), 0, Int(newUnsafeSocketAddressLength()))
        return sa
    }

    static func freeUnsafeSocketAddress(sa: UnsafeMutablePointer<sockaddr>) {
        free(sa)
    }
}

