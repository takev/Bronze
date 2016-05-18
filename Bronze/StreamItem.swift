//
//  StreamItem.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-14.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

enum StreamItem {
case Bind(SocketAddress)
case Connect(SocketAddress)
case Shutdown
case Data([UInt8])
case Datagram([UInt8], SocketAddress)
}

