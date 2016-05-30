//
//  Socket.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-14.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public class Socket {
    let fileDescriptor: Int32
    var localAddress: SocketAddress?
    var remoteAddress: SocketAddress?

    var blocking: Bool {
        get {
            switch fcntlReturningInt32(F_GETFL) {
            case .Success(let flags) where (flags & O_NONBLOCK) > 0:
                return false
            case .Success(_):
                return true
            case .Error(let error):
                preconditionFailure("Could not fcntl(F_GETFL): \(error)")
            }
        }
        set {
            switch fcntlReturningInt32(F_GETFL) {
            case .Success(let oldFlags):
                let newFlags = newValue ? (oldFlags & ~O_NONBLOCK) : (oldFlags | O_NONBLOCK)

                switch fcntl(F_SETFL, newFlags) {
                case .Success():
                    break
                case .Error(let error):
                    preconditionFailure("Could not fcntl(F_SETFL): \(error)")
                }
            case .Error(let error):
                preconditionFailure("Could not fcntl(F_GETFL): \(error)")
            }
        }
    }

    init(fileDescriptor: Int32) {
        self.fileDescriptor = fileDescriptor
    }

    init(fileDescriptor: Int32, remoteAddress: SocketAddress) {
        self.fileDescriptor = fileDescriptor
        self.remoteAddress = remoteAddress
    }

    init(fileDescriptor: Int32, localAddress: SocketAddress) {
        self.fileDescriptor = fileDescriptor
        self.localAddress = localAddress
    }

    deinit {
        switch Foundation.close(self.fileDescriptor) {
        case 0:
            break
        case -1:
            Log.error("Could not close() socket. %@", OSError())
        default:
            preconditionFailure("Unexpected return code from close()")
        }
    }

    func listen(backlog: Int32 = 5) -> OptionalOSError<Void> {
        switch Foundation.listen(self.fileDescriptor, backlog) {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from listen()")
        }
    }

    func connect(remoteAddress: SocketAddress) -> OptionalOSError<Void> {
        let sa = remoteAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        switch Foundation.connect(self.fileDescriptor, sa, remoteAddress.length) {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from connect()")
        }
    }

    func setsockopt(level: Int32, _ name: Int32, _ value: Any) -> OptionalOSError<Void> {
        let ret: Int32

        switch value {
        case let x as Bool:
            var intValue = Int32(x ? 1 : 0)
            ret = Foundation.setsockopt(self.fileDescriptor, level, name, &intValue, UInt32(sizeofValue(intValue)))

        default:
            preconditionFailure("Unknown Type for value of sockoption")
        }

        switch ret {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from connect()")
        }
    }

    func fcntl(request: Int32, _ value: Any) -> OptionalOSError<Void> {
        let ret: Int32

        switch value {
        case let x as Bool:
            let intValue = Int32(x ? 1 : 0)
            ret = fcntl_setint(self.fileDescriptor, request, intValue)

        case let x as Int32:
            let intValue = x
            ret = fcntl_setint(self.fileDescriptor, request, intValue)

        default:
            preconditionFailure("Unknown Type for value of sockoption")
        }

        switch ret {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from connect()")
        }
    }

    func fcntlReturningInt32(request: Int32) -> OptionalOSError<Int32> {
        let ret: Int32
        var intValue: Int32 = 0

        ret = fcntl_getint(self.fileDescriptor, request, &intValue)

        switch ret {
        case 0:
            return .Success(intValue)
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from connect()")
        }
    }

    func accept() -> OptionalOSError<Socket> {
        let sa = SocketAddress.newUnsafeSocketAddress()
        var saLength = SocketAddress.newUnsafeSocketAddressLength()
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        switch Foundation.accept(self.fileDescriptor, sa, &saLength) {
        case let fileDescriptor where fileDescriptor >= 0:
            return .Success(Socket(fileDescriptor: fileDescriptor, remoteAddress: SocketAddress(sa)))
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from accept()")
        }
    }

    func bind(localAddress: SocketAddress) -> OptionalOSError<Void> {
        precondition(self.localAddress == nil, "Local address can not be bound yet")

        self.localAddress = localAddress
        
        let sa = localAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        switch Foundation.bind(self.fileDescriptor, sa, localAddress.length) {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from bind()")
        }
    }

    func send(data: [UInt8]) -> OptionalOSError<Int> {
        let flags: Int32 = 0

        switch Foundation.send(self.fileDescriptor, data, data.count, flags) {
        case -1:
            return .Error(OSError())
        case let bytesSent where bytesSent >= 0:
            return .Success(bytesSent)
        default:
            preconditionFailure("Unexpected return code from sendto()")
        }
    }

    func sendto(data: [UInt8], remoteAddress: SocketAddress) -> OptionalOSError<Int> {
        let flags: Int32 = 0

        let sa = remoteAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        switch Foundation.sendto(self.fileDescriptor, data, data.count, flags, sa, remoteAddress.length) {
        case -1:
            return .Error(OSError())
        case let bytesSent where bytesSent >= 0:
            return .Success(bytesSent)
        default:
            preconditionFailure("Unexpected return code from sendto()")
        }
    }

    func recv(expectedDataLength: Int) -> OptionalOSError<ArraySlice<UInt8>> {
        var data = Array<UInt8>(count: expectedDataLength, repeatedValue: 0)

        let flags: Int32 = 0

        switch Foundation.recv(self.fileDescriptor, &data, data.count, flags) {
        case -1:
            return .Error(OSError())
        case let bytesReceived where bytesReceived >= 0:
            return .Success(data[0 ..< bytesReceived])
        default:
            preconditionFailure("Unexpected return code from recv()")
        }
    }

    func recvfrom(expectedDataLength: Int) -> OptionalOSError<(ArraySlice<UInt8>, SocketAddress)> {
        var data = Array<UInt8>(count: expectedDataLength, repeatedValue: 0)
        let flags: Int32 = 0

        let sa = SocketAddress.newUnsafeSocketAddress()
        var saLength = SocketAddress.newUnsafeSocketAddressLength()
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        switch Foundation.recvfrom(self.fileDescriptor, &data, data.count, flags, sa, &saLength) {
        case -1:
            return .Error(OSError())
        case let bytesReceived where bytesReceived >= 0:
            let receivedData = data[0 ..< bytesReceived]
            let receivedDataAndAddress = (receivedData, SocketAddress(sa))
            return .Success(receivedDataAndAddress)
        default:
            preconditionFailure("Unexpected return code from recvfrom()")
        }
    }

    func shutdown(how: Int32) -> OptionalOSError<Void> {
        switch Foundation.shutdown(self.fileDescriptor, how) {
        case 0:
            return .Success()
        case -1:
            return .Error(OSError())
        default:
            preconditionFailure("Unexpected return code from shutdown()")
        }

    }

    static func socket(domain: Int32, type: Int32, prot: Int32 = 0) -> OptionalOSError<Socket> {
        switch  Foundation.socket(domain, type, prot) {
        case -1:
            return .Error(OSError())
        case let fileDescriptor where fileDescriptor >= 0:
            return .Success(Socket(fileDescriptor: fileDescriptor))
        default:
            preconditionFailure("Unexpected return code from socket()")
        }
    }
}