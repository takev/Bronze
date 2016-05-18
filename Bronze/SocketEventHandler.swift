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
    var state           = SocketEventState.Idle
    var itemsToSend     = Ring<StreamItem>(size: 100)
    var receivedItems   = Ring<StreamItem>(size: 100)

    var socket: Socket

    override var optionalFileDescriptor: Int32? {
        return socket.fileDescriptor
    }

    init(loop: EventLoop, socket: Socket) {
        self.socket = socket
        super.init(loop: loop)
    }

    override var waitingUntilReadable: Bool {
        return false
    }

    override var waitingUntilWritable: Bool {
        return !itemsToSend.empty
    }

    override func isWritable() {
        items_to_send_loop: while let item = itemsToSend.peekFront() {
            precondition(state != SocketEventState.Aborted && state != SocketEventState.Disconnected)

            switch item {
            case StreamItem.Bind(let localAddress):
                precondition(state != SocketEventState.Connected && state != SocketEventState.Bounded)

                switch socket.bind(localAddress) {
                case OptionalOSError.Success:
                    state = SocketEventState.Bounded
                    itemsToSend.popFront()

                case OptionalOSError.Error(let error):
                    Log.error("Could not bind to %@. %@", localAddress, error)
                    state = SocketEventState.Aborted
                    itemsToSend.clear()
                    break items_to_send_loop
                }

            case StreamItem.Connect(let remoteAddress):
                precondition(state != SocketEventState.Connected)

                switch socket.connect(remoteAddress) {
                case OptionalOSError.Success:
                    state = SocketEventState.Connected
                    itemsToSend.popFront()

                case OptionalOSError.Error(EINPROGRESS):
                    break items_to_send_loop

                case OptionalOSError.Error(let error):
                    Log.error("Could not connect to %@. %@", remoteAddress, error)
                    state = SocketEventState.Aborted
                    itemsToSend.clear()
                    break items_to_send_loop
                }

            case StreamItem.Datagram(let data, let remoteAddress):
                precondition(state != SocketEventState.Connected)

                switch socket.send(data, remoteAddress: remoteAddress) {
                case OptionalOSError.Success(0):
                    break items_to_send_loop

                case OptionalOSError.Success(let size) where size == data.count:
                    itemsToSend.popFront()

                case OptionalOSError.Success(let size):
                    Log.error("Only %@ bytes of datagram with size of %@ bytes was send to %@", size, data.count, remoteAddress)

                case OptionalOSError.Error(EINPROGRESS):
                    break items_to_send_loop

                case OptionalOSError.Error(let error):
                    Log.error("Could send datagram to %@. %@", remoteAddress, error)
                    state = SocketEventState.Aborted
                    itemsToSend.clear()
                    break items_to_send_loop
                }

            case StreamItem.Data(let data):
                precondition(state == SocketEventState.Connected)

                switch socket.send(data) {
                case OptionalOSError.Success(0):
                    break items_to_send_loop

                case OptionalOSError.Success(let size) where size == data.count:
                    itemsToSend.popFront()

                case OptionalOSError.Success(let size):
                    // Only partial data was send, put back in the queue the data that has not been send yet.
                    itemsToSend.replaceFront(StreamItem.Data(Array<UInt8>(data[size ..< data.count])))

                case OptionalOSError.Error(EINPROGRESS):
                    break items_to_send_loop

                case OptionalOSError.Error(let error):
                    Log.error("Could send data to %@. %@", socket.remoteAddress, error)
                    state = SocketEventState.Aborted
                    itemsToSend.clear()
                    break items_to_send_loop
                }

            case StreamItem.Shutdown:
                precondition(state == SocketEventState.Connected)


            }
        }
    }

    func bind(localAddress: SocketAddress) {
        let item = StreamItem.Bind(localAddress)
        itemsToSend.pushBack(item)

        if itemsToSend.count == 1 {
            isWritable()
        }
    }

    func connect(remoteAddress: SocketAddress) {
        let item = StreamItem.Connect(remoteAddress)
        itemsToSend.pushBack(item)

        if itemsToSend.count == 1 {
            isWritable()
        }
    }

    func send(data: [UInt8]) {
        let item = StreamItem.Data(data)
        itemsToSend.pushBack(item)

        if itemsToSend.count == 1 {
            isWritable()
        }
    }

    func sendTo(data: [UInt8], remoteAddress: SocketAddress) {
        let item = StreamItem.Datagram(data, remoteAddress)
        itemsToSend.pushBack(item)

        if itemsToSend.count == 1 {
            isWritable()
        }
    }

    func shutdown() {
        let item = StreamItem.Shutdown
        itemsToSend.pushBack(item)

        if itemsToSend.count == 1 {
            isWritable()
        }
    }

}