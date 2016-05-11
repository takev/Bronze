//
//  LogDestinationStderr.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-08.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public class LogDestinationStderr: LogDestination {
    public func print(message: String) {
        let message = message + "\n"

        guard let message_cstr = message.cStringUsingEncoding(NSUTF8StringEncoding) else {
            preconditionFailure("Message can not be converted to utf8 C string.")
        }

        write(2, message_cstr, message_cstr.count - 1)
    }
}
