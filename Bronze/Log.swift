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

public class Log {
    static var sharedInstance: Log = Log()

    var logRing: Ring<LogItem>
    var logDestination: LogDestination

    init(logDestination: LogDestination = LogDestinationStderr()) {
        self.logDestination = logDestination
        logRing = Ring<LogItem>(size: 4096)

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            self.logLoop()
        }
    }

    func logLoop() {
        while true {
            while let item = logRing.popFront() {
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

        while !sharedInstance.logRing.pushBack(logItem) {
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

