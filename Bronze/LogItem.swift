//
//  LogItem.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-07.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

struct LogItem {
    let timestamp: Timestamp
    let priority: LogPriority
    let msg: String
    let params: [Any]

}