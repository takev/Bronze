//
//  Log.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-07.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public class Log {
    static var sharedInstance: Log = Log()

    var logRing: Ring<LogItem>
    var logDestination: LogDestination

    init(logDestination: LogDestination = LogDestinationStderr()) {
        self.logDestination = logDestination
        logRing = Ring<LogItem>(nrItems: 4096)

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.logLoop()
        }
    }

    func logLoop() {
        while true {
            while let item = logRing.remove() {
                let fullMessage = String(format: item.msg, parameters: item.params)
                let logLine = String(format: "%@ %@ %@", item.timestamp, item.priority, fullMessage)

                logDestination.print(logLine)

                switch item.priority {
                case LogPriority.Emergency: return
                case LogPriority.Exit: return
                default: break
                }
            }
            usleep(100000)
        }
    }


    static func log(priority: LogPriority, msg: String, params: [Any]) {
        let logItem = LogItem(timestamp: Timestamp.now(), priority: priority, msg: msg, params: params)

        while !sharedInstance.logRing.add(logItem) {
            usleep(10000)
        }
    }

    static func debug(msg: String, _ params: Any...) {
        log(LogPriority.Debug, msg: msg, params: params)
    }

    static func notice(msg: String, _ params: Any...) {
        log(LogPriority.Notice, msg: msg, params: params)
    }

    static func audit(msg: String, _ params: Any...) {
        log(LogPriority.Audit, msg: msg, params: params)
    }

    static func warning(msg: String, _ params: Any...) {
        log(LogPriority.Warning, msg: msg, params: params)
    }

    static func error(msg: String, _ params: Any...) {
        log(LogPriority.Error, msg: msg, params: params)
    }

    static func critical(msg: String, _ params: Any...) {
        log(LogPriority.Critical, msg: msg, params: params)
    }

    static func emergency(msg: String, _ params: Any...) {
        log(LogPriority.Emergency, msg: msg, params: params)
    }

    static func exit(msg: String, _ params: Any...) {
        log(LogPriority.Exit, msg: msg, params: params)
    }
}

