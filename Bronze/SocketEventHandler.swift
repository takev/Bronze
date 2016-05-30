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

public enum SocketEventState {
case Idle
case Bounded
case Connected
case Disconnected
case Aborted
}

public class SocketEventHandler: EventHandler {
    var state               = SocketEventState.Idle

    var isPotentialWritable = true
    var itemsToSend         = Ring<StreamItem>(size: 100)
    var receivedItems       = Ring<StreamItem>(size: 100)

    var socket: Socket

    override var optionalFileDescriptor: Int32? {
        return socket.fileDescriptor
    }

    init(loop: EventLoop, socket: Socket) {
        self.socket = socket
        super.init(loop: loop)
    }

    override var isReadable: Bool {
        return false
    }

    override var isWritable: Bool {
        return !itemsToSend.empty
    }

    func abort() -> Bool {
        state = .Aborted
        itemsToSend.clear()
        receivedItems.clear()
        return false
    }

    func handleWritableBind(localAddress: SocketAddress) -> Bool {
        precondition(state != .Connected && state != .Bounded)

        switch socket.bind(localAddress) {
        case .Success:
            state = .Bounded
            itemsToSend.popFront()
            return true

        case .Error(let error):
            Log.error("Could not bind to %@. %@", localAddress, error)
            return abort()
        }
    }

    func handleWritableConnect(remoteAddress: SocketAddress) -> Bool {
        precondition(state != SocketEventState.Connected)

        switch socket.connect(remoteAddress) {
        case .Success:
            state = .Connected
            itemsToSend.popFront()
            return true

        case .Error(EINPROGRESS), .Error(EALREADY):
            return false

        case .Error(EINTR):
            Log.warning("Interupt on non blocking connect() system call.")
            return false

        case .Error(let error):
            Log.error("Could not connect to %@. %@", remoteAddress, error)
            return abort()
        }
    }

    func handleWritableDatagram(data: [UInt8], remoteAddress: SocketAddress) -> Bool {
        precondition(state != SocketEventState.Connected)

        switch socket.sendto(data, remoteAddress: remoteAddress) {
        case .Success(0):
            return false

        case .Success(let size) where size == data.count:
            itemsToSend.popFront()
            return true

        case .Success(let size):
            Log.error("Only %@ bytes of datagram with size of %@ bytes was send to %@", size, data.count, remoteAddress)
            return abort()

        case .Error(EAGAIN):
            return false

        case .Error(EINTR):
            Log.warning("Interupt on non blocking sendto() system call.")
            return false

        case .Error(let error):
            Log.error("Could send datagram to %@. %@", remoteAddress, error)
            return abort()
        }
    }

    func handleWritableData(data: [UInt8]) -> Bool {
        precondition(state == SocketEventState.Connected)

        switch socket.send(data) {
        case .Success(0):
            return false

        case .Success(let size) where size == data.count:
            itemsToSend.popFront()
            return true

        case .Success(let size):
            // Only partial data was send, put back in the queue the data that has not been send yet.
            itemsToSend.replaceFront(StreamItem.Data(Array<UInt8>(data[size ..< data.count])))
            return false

        case .Error(EAGAIN):
            return false

        case .Error(EINTR):
            Log.warning("Interupt on non blocking sendto() system call.")
            return false

        case .Error(let error):
            Log.error("Could send data to %@. %@", socket.remoteAddress, error)
            return abort()
        }
    }

    func handleWritableShutdown() -> Bool {
        precondition(state == SocketEventState.Connected)

        switch socket.shutdown(SHUT_WR) {
        case .Success():
            itemsToSend.popFront()
            state = .Disconnected
            return false

        case .Error(let error):
            Log.error("Could send data to %@. %@", socket.remoteAddress, error)
            return abort()
        }
    }

    /// - returns: true when all items were send.
    func handleWritableLoop() -> Bool {
        while let item = itemsToSend.peekFront() {
            precondition(state != .Aborted && state != .Disconnected)

            switch item {
            case .Bind(let localAddress):
                guard handleWritableBind(localAddress) else {
                    return false
                }

            case .Connect(let remoteAddress):
                guard handleWritableConnect(remoteAddress) else {
                    return false
                }

            case .Datagram(let data, let remoteAddress):
                guard handleWritableDatagram(data, remoteAddress: remoteAddress) else {
                    return false
                }

            case .Data(let data):
                guard handleWritableData(data) else {
                    return false
                }

            case .Shutdown:
                guard handleWritableShutdown() else {
                    return false
                }
            }
        }
        return true
    }

    override func handleWritable() {
        isPotentialWritable = handleWritableLoop()
    }

    func handleOptionalWritable() {
        if isPotentialWritable {
            handleWritable()
        }
    }

    func bind(localAddress: SocketAddress) {
        let item = StreamItem.Bind(localAddress)
        itemsToSend.pushBack(item)
        handleOptionalWritable()
    }

    func connect(remoteAddress: SocketAddress) {
        let item = StreamItem.Connect(remoteAddress)
        itemsToSend.pushBack(item)
        handleOptionalWritable()
    }

    func send(data: [UInt8]) {
        let item = StreamItem.Data(data)
        itemsToSend.pushBack(item)
        handleOptionalWritable()
    }

    func sendTo(data: [UInt8], remoteAddress: SocketAddress) {
        let item = StreamItem.Datagram(data, remoteAddress)
        itemsToSend.pushBack(item)
        handleOptionalWritable()
    }

    func shutdown() {
        let item = StreamItem.Shutdown
        itemsToSend.pushBack(item)
        handleOptionalWritable()
    }

}