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
