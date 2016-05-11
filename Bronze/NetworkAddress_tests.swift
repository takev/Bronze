//
//  NetworkAddress_tests.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-05.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import XCTest
@testable import Bronze

class NetworkAddress_tests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIPv4Initialization() {
        let address = NetworkAddress.IPv4Address([1, 2, 3, 4], 1234)
        let sock_address = address.socketAddress

        let sock_address_bytes = UnsafeMutablePointer<UInt8>(sock_address)
        let sock_address_data = NSData(bytes: sock_address_bytes, length: Int(sock_address_bytes[0]))

        Swift.print(sock_address_data)

        XCTAssertEqual(
            sock_address_data,
            NSData(
                bytes: [
                    UInt8(sizeof(sockaddr_in)),
                    UInt8(AF_INET),
                    0x04, 0xd2,
                    1, 2, 3, 4,
                    0, 0, 0, 0,
                    0, 0, 0, 0
                ] as [UInt8],
                length: sizeof(sockaddr_in)
            )
        )

        sock_address.dealloc(1)
    }


}
