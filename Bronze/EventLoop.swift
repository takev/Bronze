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

class EventLoop {
    static let sharedInstance = EventLoop()
    var eventHandlers: [EventHandler] = []

    let polls_p  = UnsafeMutablePointer<pollfd>.alloc(256)

    init() {

    }

    func iteration() {
        var pollHandlers: [EventHandler] = []
        var timeoutHandlers: [EventHandler] = []
        var closestDate = Timestamp.endOfTime()

        for eventHandler in eventHandlers {
            // Setup file descriptor events for poll().
            if eventHandler.waitingUntilReadable || eventHandler.waitingUntilWritable {
                guard let fileDescriptor = eventHandler.optionalFileDescriptor else {
                    preconditionFailure("File descriptor must be set.")
                }

                polls_p[pollHandlers.count].fd = Int32(fileDescriptor)
                polls_p[pollHandlers.count].events = Int16(
                    (eventHandler.waitingUntilReadable ? POLLIN : Int32(0)) |
                    (eventHandler.waitingUntilWritable ? POLLOUT: Int32(0))
                )
                polls_p[pollHandlers.count].revents = 0
                pollHandlers.append(eventHandler)
            }

            // Wait until timeout
            if let waitingUntilDate = eventHandler.optionalWaitingUntilDate {
                if waitingUntilDate < closestDate {
                    closestDate = waitingUntilDate
                }

                timeoutHandlers.append(eventHandler)
            }
        }

        // Wait a maximum of 1 minute
        let timeout = clamp(closestDate - Timestamp.now(), minimum: Period.zero(), maximum: Period.minutes(1))

        // Poll waits for file descriptor events, but can also be used as a more accurate sleep when there are no file descriptor
        // events to read from.
        poll(polls_p, UInt32(pollHandlers.count), Int32(timeout.numberOfMilliseconds))

        // Execute all the writes, this will clear the buffers first.
        for (i, eventHandler) in pollHandlers.enumerate() {
            if (polls_p[i].revents & Int16(POLLOUT)) > 0 {
                eventHandler.isWritable()
            }
        }

        // Execute all the reads.
        for (i, eventHandler) in pollHandlers.enumerate() {
            if (polls_p[i].revents & Int16(POLLIN)) > 0 {
                eventHandler.isReadable()
            }
        }

        // The timeouts may have been set because it was waiting for a read event, so timeouts needs
        // to be executed after all reads are executed.
        for eventHandler in timeoutHandlers {
            if let waitingUntilDate = eventHandler.optionalWaitingUntilDate {
                // Compare to the current time, as the event handlers may have taken some time to execute.
                if waitingUntilDate < Timestamp.now() {
                    eventHandler.dateHasPassed()
                }
            }
        }

    }

}