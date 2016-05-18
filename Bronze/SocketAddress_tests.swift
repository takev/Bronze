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

import XCTest
@testable import Bronze

class SocketAddress_tests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIPv4Initialization() {
        let socketAddress = SocketAddress.IPv4([1,2,3,4], 5000)
        let sa = socketAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        let result = NSData(bytes: sa, length:Int(socketAddress.length))
        let expected_bytes: [UInt8] = [
            16,                     // sockaddr_in.sin_length
            UInt8(AF_INET),         // sockaddr_in.sin_family
            0x13, 0x88,             // sockaddr_in.sin_port
            1, 2, 3, 4,             // sockaddr_in.sin_addr
            0, 0, 0, 0, 0, 0, 0, 0  // sockaddr_in.sin_zero
        ]
        let expected = NSData(bytes: expected_bytes, length:expected_bytes.count)

        XCTAssertEqual(result, expected)
    }

    func testIPv6Initialization() {
        let socketAddress = SocketAddress.IPv6([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], 4000)
        let sa = socketAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        let result = NSData(bytes: sa, length:Int(socketAddress.length))
        let expected_bytes: [UInt8] = [
            28,                                                     // sockaddr_in6.sin6_length
            UInt8(AF_INET6),                                        // sockaddr_in6.sin6_family
            0x0f, 0xa0,                                             // sockaddr_in6.sin6_port
            0, 0, 0, 0,                                             // sockaddr_in6.sin6_flowinfo
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,  // sockaddr_in6.sin6_addr
            0, 0, 0, 0                                              // sockaddr_in6.sin6_scope_id
        ]
        let expected = NSData(bytes: expected_bytes, length:expected_bytes.count)

        XCTAssertEqual(result, expected)
    }

    func testUnixInitialization() {
        let socketAddress = SocketAddress.UNIX("/foo")
        let sa = socketAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        let result = NSData(bytes: sa, length:Int(socketAddress.length))
        let expected_bytes: [UInt8] = [
            106,                                                    // sockaddr_in6.su_length
            UInt8(AF_UNIX),                                         // sockaddr_in6.su_family
            47, 102, 111, 111, 0                                    // sockaddr_in6.su_path
        ] + Array<UInt8>(count: 99, repeatedValue: 0)

        let expected = NSData(bytes: expected_bytes, length:expected_bytes.count)

        XCTAssertEqual(result, expected)
    }

    func testIPv4Description() {
        let socketAddress = SocketAddress.IPv4([1,2,3,4], 5000)

        XCTAssertEqual(socketAddress.description, "1.2.3.4:5000")
    }

    func testIPv6Description() {
        let socketAddress1 = SocketAddress.IPv6([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], 4000)
        XCTAssertEqual(socketAddress1.description, "[102:304:506:708:90a:b0c:d0e:f10]:4000")

        let socketAddress2 = SocketAddress.IPv6([1,0,0,0,0,0,7,8,9,10,11,12,13,14,15,16], 4000)
        XCTAssertEqual(socketAddress2.description, "[100::708:90a:b0c:d0e:f10]:4000")

        let socketAddress3 = SocketAddress.IPv6([0,0,0,0,0,0,7,8,9,10,11,12,13,14,15,16], 4000)
        XCTAssertEqual(socketAddress3.description, "[::708:90a:b0c:d0e:f10]:4000")

        let socketAddress4 = SocketAddress.IPv6([1,2,3,4,5,6,7,8,9,10,11,12,0,0,0,0], 4000)
        XCTAssertEqual(socketAddress4.description, "[102:304:506:708:90a:b0c::]:4000")

        let socketAddress5 = SocketAddress.IPv6([0,0,0,0,0,0,7,8,9,10,11,12,0,0,0,0], 4000)
        XCTAssertEqual(socketAddress5.description, "[::708:90a:b0c:0:0]:4000")
    }

    func testUnixDescription() {
        let socketAddress = SocketAddress.UNIX("/foo")
        XCTAssertEqual(socketAddress.description, "/foo")
    }


}