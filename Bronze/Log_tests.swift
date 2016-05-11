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

class LogDestinationMock : LogDestination {
    var messages = Array<String>()

    func print(message: String) {
        messages.append(message)
    }
}

class Log_tests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testLog() {
        let logDestination = LogDestinationMock()
        Log.sharedInstance = Log(logDestination: logDestination)

        Log.warning("hi %@ hi", 45)
        Log.exit("Bye")
        usleep(1000000)

        XCTAssertTrue(logDestination.messages[0].hasSuffix(" WARNING hi 45 hi"))
        XCTAssertTrue(logDestination.messages[1].hasSuffix(" EXIT Bye"))
    }

}
