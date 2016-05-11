//
//  DHGroup.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-16.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

struct DHGroup {
    let size: Int
    let prime: BigInt
    let generator: BigInt

    init(size: Int, prime: BigInt, generator: BigInt) {
        self.size = size
        self.prime = prime
        self.generator = generator
    }
}