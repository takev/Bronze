//
//  DH_tests.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-18.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import XCTest
@testable import Bronze

class DH_tests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testIntInitialization() {
        guard let AliceSession = DHGroups.sharedInstance.startSession("RFC3526:1536") else {
            XCTFail("Could not set up Alice session")
            return
        }

        guard let BobSession = DHGroups.sharedInstance.startSession("RFC3526:1536") else {
            XCTFail("Could not set up Bob session")
            return
        }

        XCTAssert(AliceSession.myPrivateKey > 0)
        XCTAssert(BobSession.myPrivateKey > 0)
        XCTAssertNotEqual(AliceSession.myPrivateKey, BobSession.myPrivateKey)

        BobSession.setTheirPublicKey(AliceSession.myPublicKey)
        AliceSession.setTheirPublicKey(BobSession.myPublicKey)

        XCTAssertEqual(BobSession.sharedSecret, AliceSession.sharedSecret)
    }


}
