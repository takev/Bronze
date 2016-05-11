//
//  LogDestination.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-08.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public protocol LogDestination {
    func print(message: String)
}
