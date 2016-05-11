//
//  Log_tests.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-07.
//  Copyright © 2016 Take Vos. All rights reserved.
//

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
