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

    func listen(backlog: Int32 = 5) -> OptionalOSError<Void> {
        if Foundation.listen(self.fileDescriptor, backlog) == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success()
        }
    }

    func connect(remoteAddress: SocketAddress) -> OptionalOSError<Void> {
        let sa = remoteAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        if Foundation.connect(self.fileDescriptor, sa, remoteAddress.length) == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success()
        }
    }

    func accept() -> OptionalOSError<Socket> {
        let sa = SocketAddress.newUnsafeSocketAddress()
        var saLength = SocketAddress.newUnsafeSocketAddressLength()
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        let fileDescriptor = Foundation.accept(self.fileDescriptor, sa, &saLength)
        if fileDescriptor != -1 {
            return OptionalOSError.Success(Socket(fileDescriptor: fileDescriptor, remoteAddress: SocketAddress(sa)))
        } else {
            return OptionalOSError.Error(OSError())
        }
    }

    func bind(localAddress: SocketAddress) -> OptionalOSError<Void> {
        precondition(self.localAddress == nil, "Local address can not be bound yet")

        self.localAddress = localAddress
        
        let sa = localAddress.unsafeSocketAddress
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        if Foundation.bind(self.fileDescriptor, sa, localAddress.length) == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success()
        }
    }

    func send(data: [UInt8], remoteAddress optionalRemoteAddress: SocketAddress? = nil) -> OptionalOSError<Int> {
        let flags: Int32 = 0

        let ret: Int
        if let remoteAddress = optionalRemoteAddress {
            let sa = remoteAddress.unsafeSocketAddress
            defer { SocketAddress.freeUnsafeSocketAddress(sa) }

            ret = Foundation.sendto(self.fileDescriptor, data, data.count, flags, sa, remoteAddress.length)

        } else {
            ret = Foundation.send(self.fileDescriptor, data, data.count, flags)
        }

        if ret == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success(ret)
        }
    }

    func recv(expectedDataLength: Int) -> OptionalOSError<ArraySlice<UInt8>> {
        var data = Array<UInt8>(count: expectedDataLength, repeatedValue: 0)

        let flags: Int32 = 0

        let ret = Foundation.recv(self.fileDescriptor, &data, data.count, flags)

        if ret == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success(data[0 ..< ret])
        }
    }

    func recvfrom(expectedDataLength: Int) -> OptionalOSError<(ArraySlice<UInt8>, SocketAddress)> {
        var data = Array<UInt8>(count: expectedDataLength, repeatedValue: 0)
        let flags: Int32 = 0

        let sa = SocketAddress.newUnsafeSocketAddress()
        var saLength = SocketAddress.newUnsafeSocketAddressLength()
        defer { SocketAddress.freeUnsafeSocketAddress(sa) }

        let ret = Foundation.recvfrom(self.fileDescriptor, &data, data.count, flags, sa, &saLength)

        if ret == -1 {
            return OptionalOSError.Error(OSError())
        } else if ret >= 0 {
            let receivedData = data[0 ..< ret]
            let receivedDataAndAddress = (receivedData, SocketAddress(sa))
            return OptionalOSError.Success(receivedDataAndAddress)
        } else {
            preconditionFailure("recvfrom was less than 0")
        }
    }

    static func socket(domain: Int32, type: Int32, prot: Int32 = 0) -> OptionalOSError<Socket> {
        let fileDescriptor = Foundation.socket(domain, type, prot)
        if fileDescriptor == -1 {
            return OptionalOSError.Error(OSError())
        } else {
            return OptionalOSError.Success(Socket(fileDescriptor: fileDescriptor))
        }
    }

}