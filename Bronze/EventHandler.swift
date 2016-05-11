//
//  EventHandler.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-22.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation


class EventHandler {
    weak var loop : EventLoop?

    var optionalFileDescriptor: Int? = nil
    var optionalWaitingUntilDate: Timestamp? = nil

    var waitingUntilReadable: Bool {
        return false
    }

    var waitingUntilWritable: Bool {
        return false
    }

    func isReadable() {
    }

    func isWritable() {
    }

    func dateHasPassed() {
    }

}
